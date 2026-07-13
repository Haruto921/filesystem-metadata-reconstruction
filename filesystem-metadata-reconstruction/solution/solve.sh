#!/bin/bash
# Oracle solution: Reconstruct filesystem metadata

set -e

ARCHIVE="/workspace/archive"
METADATA="/workspace/metadata"
REPORTS="/workspace/reports"

echo "=== Metadata Reconstruction Oracle ==="
echo

# Phase 1: Inspect archive contents
echo "Phase 1: Scanning archive..."
declare -A FILE_MAP
declare -A DIR_MAP
ID_COUNTER=1

# Find all directories first (sorted for determinism)
while IFS= read -r dir; do
    rel_path="${dir#$ARCHIVE/}"
    if [ "$rel_path" = "$ARCHIVE" ] || [ -z "$rel_path" ]; then
        continue
    fi
    DIR_MAP["$rel_path"]="obj-$(printf '%03d' $ID_COUNTER)"
    ID_COUNTER=$((ID_COUNTER + 1))
done < <(find "$ARCHIVE" -type d | sort)

# Find all files (sorted for determinism)
while IFS= read -r file; do
    rel_path="${file#$ARCHIVE/}"
    FILE_MAP["$rel_path"]="obj-$(printf '%03d' $ID_COUNTER)"
    ID_COUNTER=$((ID_COUNTER + 1))
done < <(find "$ARCHIVE" -type f | sort)

# Phase 2: Build catalog
echo "Phase 2: Building catalog..."

OBJECTS="[]"

# Add root directory concept implicitly through null parent_id
# Add directories
for dir in $(echo "${!DIR_MAP[@]}" | tr ' ' '\n' | sort); do
    id="${DIR_MAP[$dir]}"
    
    # Determine parent
    parent_path=$(dirname "$dir")
    if [ "$parent_path" = "." ]; then
        parent_id="null"
    else
        parent_id="\"${DIR_MAP[$parent_path]}\""
    fi
    
    obj="{\"id\":\"$id\",\"path\":\"$dir\",\"type\":\"directory\",\"checksum\":null,\"size\":0,\"parent_id\":$parent_id}"
    OBJECTS=$(echo "$OBJECTS" | jq --argjson obj "$obj" '. + [$obj]')
done

# Add files
for file in $(echo "${!FILE_MAP[@]}" | tr ' ' '\n' | sort); do
    id="${FILE_MAP[$file]}"
    filepath="$ARCHIVE/$file"
    
    checksum=$(sha256sum "$filepath" | cut -d' ' -f1)
    size=$(stat -c%s "$filepath")
    
    # Determine parent
    parent_path=$(dirname "$file")
    if [ "$parent_path" = "." ]; then
        parent_id="null"
    else
        parent_id="\"${DIR_MAP[$parent_path]}\""
    fi
    
    obj="{\"id\":\"$id\",\"path\":\"$file\",\"type\":\"file\",\"checksum\":\"$checksum\",\"size\":$size,\"parent_id\":$parent_id}"
    OBJECTS=$(echo "$OBJECTS" | jq --argjson obj "$obj" '. + [$obj]')
done

# Write catalog
echo "$OBJECTS" | jq '{objects: .}' > "$METADATA/catalog.json"
echo "  Created catalog.json with $(echo "$OBJECTS" | jq 'length') objects"

# Phase 3: Regenerate indexes
echo "Phase 3: Regenerating indexes..."
mkdir -p "$METADATA/indexes"

# ID index
jq '[.objects[] | {(.id): .}] | add' "$METADATA/catalog.json" > "$METADATA/indexes/id_index.json"

# Checksum index (files only)
jq '[.objects[] | select(.type == "file") | {(.checksum): .id}] | add' "$METADATA/catalog.json" > "$METADATA/indexes/checksum_index.json"

# Type index
jq 'reduce .objects[] as $o ({}; .[$o.type] += [$o.id])' "$METADATA/catalog.json" > "$METADATA/indexes/type_index.json"

# Path index
jq '[.objects[] | {(.path): .id}] | add' "$METADATA/catalog.json" > "$METADATA/indexes/path_index.json"

echo "  Created 4 indexes"

# Phase 4: Regenerate manifests
echo "Phase 4: Regenerating manifests..."
mkdir -p "$METADATA/manifests"
rm -f "$METADATA/manifests"/*.manifest

# Create root manifest for objects with null parent_id
ROOT_CHILDREN=$(jq -r '[.objects[] | select(.parent_id == null) | .id]' "$METADATA/catalog.json")
echo "{\"children\": $ROOT_CHILDREN}" > "$METADATA/manifests/root.manifest"

# Get unique parent paths from catalog (directories that have children)
PARENT_PATHS=$(jq -r '.objects[] | select(.type == "directory" and .path != null) | .path' "$METADATA/catalog.json" | sort)

for parent in $PARENT_PATHS; do
    manifest_name=$(echo "$parent" | tr '/' '_')
    
    # Get the ID of this parent directory
    parent_id=$(jq -r --arg p "$parent" '.objects[] | select(.path == $p) | .id' "$METADATA/catalog.json")
    
    # Find children of this directory
    children=$(jq -r --arg pid "$parent_id" '[.objects[] | select(.parent_id == $pid) | .id]' "$METADATA/catalog.json")
    
    echo "{\"children\": $children}" > "$METADATA/manifests/${manifest_name}.manifest"
done

# Count manifests
MANIFEST_COUNT=$(ls -1 "$METADATA/manifests/"*.manifest 2>/dev/null | wc -l)
echo "  Created $MANIFEST_COUNT manifests"

# Phase 5: Generate report
echo "Phase 5: Generating reconstruction report..."
mkdir -p "$REPORTS"

FILE_COUNT=$(jq '[.objects[] | select(.type == "file")] | length' "$METADATA/catalog.json")
DIR_COUNT=$(jq '[.objects[] | select(.type == "directory")] | length' "$METADATA/catalog.json")

cat > "$REPORTS/reconstruction.json" << REPORT
{
  "status": "complete",
  "timestamp": "reconstructed",
  "summary": {
    "total_objects": $((FILE_COUNT + DIR_COUNT)),
    "files": $FILE_COUNT,
    "directories": $DIR_COUNT,
    "indexes_regenerated": 4,
    "manifests_regenerated": $MANIFEST_COUNT
  },
  "validation": "pending"
}
REPORT

echo "  Created reconstruction report"

# Phase 6: Validate
echo "Phase 6: Running validation..."
if /workspace/tools/full-validation.sh; then
    jq '.validation = "passed"' "$REPORTS/reconstruction.json" > "$REPORTS/reconstruction.tmp" && mv "$REPORTS/reconstruction.tmp" "$REPORTS/reconstruction.json"
    echo
    echo "=== RECONSTRUCTION COMPLETE ==="
    exit 0
else
    jq '.validation = "failed"' "$REPORTS/reconstruction.json" > "$REPORTS/reconstruction.tmp" && mv "$REPORTS/reconstruction.tmp" "$REPORTS/reconstruction.json"
    echo
    echo "=== RECONSTRUCTION FAILED VALIDATION ==="
    exit 1
fi
