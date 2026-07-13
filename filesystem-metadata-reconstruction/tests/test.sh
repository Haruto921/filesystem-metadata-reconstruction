#!/bin/bash
# Visible test: Check required outputs exist

METADATA="/workspace/metadata"
REPORTS="/workspace/reports"
TOOLS="/workspace/tools"

FAILED=0

echo "=== Running Visible Tests ==="
echo

# Test 1: catalog.json exists and is valid JSON
if [ -f "$METADATA/catalog.json" ] && jq empty "$METADATA/catalog.json" 2>/dev/null; then
    echo "[PASS] catalog.json exists and is valid JSON"
else
    echo "[FAIL] catalog.json missing or invalid"
    FAILED=1
fi

# Test 2: indexes directory exists with files
if [ -d "$METADATA/indexes" ] && [ "$(ls -A $METADATA/indexes 2>/dev/null)" ]; then
    echo "[PASS] indexes directory contains files"
else
    echo "[FAIL] indexes directory missing or empty"
    FAILED=1
fi

# Test 3: manifests directory exists with files
if [ -d "$METADATA/manifests" ] && [ "$(ls -A $METADATA/manifests 2>/dev/null)" ]; then
    echo "[PASS] manifests directory contains files"
else
    echo "[FAIL] manifests directory missing or empty"
    FAILED=1
fi

# Test 4: reconstruction report exists
if [ -f "$REPORTS/reconstruction.json" ] && jq empty "$REPORTS/reconstruction.json" 2>/dev/null; then
    echo "[PASS] reconstruction.json exists and is valid JSON"
else
    echo "[FAIL] reconstruction.json missing or invalid"
    FAILED=1
fi

# Test 5: validation tools pass
if [ -x "$TOOLS/full-validation.sh" ]; then
    if "$TOOLS/full-validation.sh" >/dev/null 2>&1; then
        echo "[PASS] all validation tools pass"
    else
        echo "[FAIL] validation tools report errors"
        FAILED=1
    fi
else
    echo "[FAIL] validation tools not found or not executable"
    FAILED=1
fi

echo
if [ "$FAILED" -eq 0 ]; then
    echo "=== ALL VISIBLE TESTS PASSED ==="
    exit 0
else
    echo "=== SOME VISIBLE TESTS FAILED ==="
    exit 1
fi
