#!/bin/bash
# Validate metadata schema

CATALOG="/workspace/metadata/catalog.json"

if [ ! -f "$CATALOG" ]; then
    echo "ERROR: catalog.json not found"
    exit 1
fi

if ! jq empty "$CATALOG" 2>/dev/null; then
    echo "ERROR: catalog.json is not valid JSON"
    exit 1
fi

if ! jq -e '.objects | type == "array"' "$CATALOG" >/dev/null 2>&1; then
    echo "ERROR: catalog must have 'objects' array"
    exit 1
fi

echo "Schema validation: PASSED"
exit 0
