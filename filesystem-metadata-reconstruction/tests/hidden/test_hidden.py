#!/usr/bin/env python3
"""Hidden tests: Deep correctness validation"""

import json
import os
import sys
import hashlib

def sha256_file(filepath):
    """Compute SHA256 of a file"""
    h = hashlib.sha256()
    with open(filepath, 'rb') as f:
        for chunk in iter(lambda: f.read(8192), b''):
            h.update(chunk)
    return h.hexdigest()

def main():
    archive_dir = "/workspace/archive"
    metadata_dir = "/workspace/metadata"
    
    errors = []
    
    # Load catalog
    catalog_path = os.path.join(metadata_dir, "catalog.json")
    try:
        with open(catalog_path) as f:
            catalog = json.load(f)
    except Exception as e:
        print(f"Cannot load catalog: {e}")
        return 1
    
    objects = catalog.get("objects", [])
    
    # Test 1: All IDs are unique
    ids = [obj["id"] for obj in objects]
    if len(ids) != len(set(ids)):
        errors.append("Duplicate IDs found in catalog")
    
    # Test 2: Every archive file is represented
    archive_files = set()
    for root, dirs, files in os.walk(archive_dir):
        for f in files:
            full_path = os.path.join(root, f)
            rel_path = os.path.relpath(full_path, archive_dir)
            archive_files.add(rel_path)
    
    catalog_files = {obj["path"] for obj in objects if obj["type"] == "file"}
    missing_files = archive_files - catalog_files
    if missing_files:
        errors.append(f"Missing files in catalog: {missing_files}")
    
    extra_files = catalog_files - archive_files
    if extra_files:
        errors.append(f"Extra files in catalog: {extra_files}")
    
    # Test 3: All checksums match actual content
    for obj in objects:
        if obj["type"] == "file":
            filepath = os.path.join(archive_dir, obj["path"])
            if os.path.exists(filepath):
                actual_checksum = sha256_file(filepath)
                if obj["checksum"] != actual_checksum:
                    errors.append(f"Checksum mismatch for {obj['path']}")
    
    # Test 4: All parent references resolve
    id_set = set(ids)
    for obj in objects:
        if obj["parent_id"] is not None:
            if obj["parent_id"] not in id_set:
                errors.append(f"Invalid parent reference: {obj['parent_id']}")
    
    # Test 5: Hierarchy is acyclic (no object is its own ancestor)
    parent_map = {obj["id"]: obj["parent_id"] for obj in objects}
    for obj_id in ids:
        visited = set()
        current = obj_id
        while current is not None:
            if current in visited:
                errors.append(f"Cyclic hierarchy detected involving {obj_id}")
                break
            visited.add(current)
            current = parent_map.get(current)
    
    # Test 6: File sizes match actual sizes
    for obj in objects:
        if obj["type"] == "file":
            filepath = os.path.join(archive_dir, obj["path"])
            if os.path.exists(filepath):
                actual_size = os.path.getsize(filepath)
                if obj["size"] != actual_size:
                    errors.append(f"Size mismatch for {obj['path']}: expected {actual_size}, got {obj['size']}")
    
    # Test 7: Indexes are consistent with catalog
    indexes_dir = os.path.join(metadata_dir, "indexes")
    id_index_path = os.path.join(indexes_dir, "id_index.json")
    if os.path.exists(id_index_path):
        with open(id_index_path) as f:
            id_index = json.load(f)
        for obj in objects:
            if obj["id"] not in id_index:
                errors.append(f"ID {obj['id']} missing from id_index")
    
    # Test 8: Manifests accurately reflect contents
    manifests_dir = os.path.join(metadata_dir, "manifests")
    if os.path.isdir(manifests_dir):
        for manifest_file in os.listdir(manifests_dir):
            if manifest_file.endswith(".manifest"):
                manifest_path = os.path.join(manifests_dir, manifest_file)
                with open(manifest_path) as f:
                    manifest = json.load(f)
                children = manifest.get("children", [])
                for child_id in children:
                    if child_id not in id_set:
                        errors.append(f"Manifest {manifest_file} references unknown ID {child_id}")
    
    if errors:
        print("Hidden tests FAILED:")
        for err in errors:
            print(f"  - {err}")
        return 1
    else:
        print("Hidden tests PASSED")
        return 0

if __name__ == "__main__":
    sys.exit(main())
