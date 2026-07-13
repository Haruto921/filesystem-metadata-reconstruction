#!/usr/bin/env python3
"""Visible test: Validate output schema and structure"""

import json
import os
import sys

def main():
    metadata_dir = "/workspace/metadata"
    reports_dir = "/workspace/reports"
    
    errors = []
    
    # Test catalog structure
    catalog_path = os.path.join(metadata_dir, "catalog.json")
    if os.path.exists(catalog_path):
        try:
            with open(catalog_path) as f:
                catalog = json.load(f)
            
            if "objects" not in catalog:
                errors.append("catalog.json missing 'objects' key")
            elif not isinstance(catalog["objects"], list):
                errors.append("catalog.objects must be a list")
            else:
                for obj in catalog["objects"]:
                    required_keys = ["id", "path", "type", "checksum", "size", "parent_id"]
                    for key in required_keys:
                        if key not in obj:
                            errors.append(f"Object missing required key: {key}")
                            break
        except json.JSONDecodeError as e:
            errors.append(f"catalog.json invalid JSON: {e}")
    else:
        errors.append("catalog.json not found")
    
    # Test report structure
    report_path = os.path.join(reports_dir, "reconstruction.json")
    if os.path.exists(report_path):
        try:
            with open(report_path) as f:
                report = json.load(f)
            
            if "status" not in report:
                errors.append("reconstruction.json missing 'status' key")
            if "summary" not in report:
                errors.append("reconstruction.json missing 'summary' key")
        except json.JSONDecodeError as e:
            errors.append(f"reconstruction.json invalid JSON: {e}")
    else:
        errors.append("reconstruction.json not found")
    
    # Test indexes exist
    indexes_dir = os.path.join(metadata_dir, "indexes")
    if os.path.isdir(indexes_dir):
        index_files = os.listdir(indexes_dir)
        if len(index_files) == 0:
            errors.append("indexes directory is empty")
    else:
        errors.append("indexes directory not found")
    
    # Test manifests exist
    manifests_dir = os.path.join(metadata_dir, "manifests")
    if os.path.isdir(manifests_dir):
        manifest_files = os.listdir(manifests_dir)
        if len(manifest_files) == 0:
            errors.append("manifests directory is empty")
    else:
        errors.append("manifests directory not found")
    
    if errors:
        print("Schema validation FAILED:")
        for err in errors:
            print(f"  - {err}")
        return 1
    else:
        print("Schema validation PASSED")
        return 0

if __name__ == "__main__":
    sys.exit(main())
