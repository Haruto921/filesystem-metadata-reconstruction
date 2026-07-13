#!/bin/bash
# Verify checksums match archive content

CATALOG="/workspace/metadata/catalog.json"
ARCHIVE="/workspace/archive"

if [ ! -f "$CATALOG" ]; then
    echo "ERROR: catalog.json not found"
    exit 1
fi

# Check each file object's checksum
FAILED=0
while IFS= read -r obj; do
    path=$(echo "$obj" | jq -r '.path')
    expected=$(echo "$obj" | jq -r '.checksum')
    
    filepath="$ARCHIVE/$path"
    if [ -f "$filepath" ]; then
        actual=$(sha256sum "$filepath" | cut -d' ' -f1)
        if [ "$expected" != "$actual" ]; then
            echo "ERROR: Checksum mismatch for $path"
            echo "  Expected: $expected"
            echo "  Actual:   $actual"
            FAILED=1
        fi
    else
        echo "ERROR: File not found: $path"
        FAILED=1
    fi
done < <(jq -c '.objects[] | select(.type == "file")' "$CATALOG")

if [ "$FAILED" -eq 0 ]; then
    echo "Checksum verification: PASSED"
    exit 0
else
    echo "Checksum verification: FAILED"
    exit 1
fi
