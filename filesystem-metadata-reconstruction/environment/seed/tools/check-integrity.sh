#!/bin/bash
# Check referential integrity

CATALOG="/workspace/metadata/catalog.json"

if [ ! -f "$CATALOG" ]; then
    echo "ERROR: catalog.json not found"
    exit 1
fi

# Check for duplicate IDs
DUPES=$(jq -r '.objects[].id' "$CATALOG" | sort | uniq -d)
if [ -n "$DUPES" ]; then
    echo "ERROR: Duplicate IDs found: $DUPES"
    exit 1
fi

# Check all parent_id references exist
PARENTS=$(jq -r '.objects[] | select(.parent_id != null) | .parent_id' "$CATALOG" | sort -u)
IDS=$(jq -r '.objects[].id' "$CATALOG" | sort -u)

for parent in $PARENTS; do
    if ! echo "$IDS" | grep -qx "$parent"; then
        echo "ERROR: Invalid parent reference: $parent"
        exit 1
    fi
done

echo "Integrity check: PASSED"
exit 0
