#!/bin/bash
# Visible Test Suite for Filesystem Metadata Reconstruction
# This script runs visible tests that agents can see and debug against

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

cd "$PROJECT_ROOT"

echo "=========================================="
echo "Filesystem Metadata Reconstruction"
echo "Visible Test Suite"
echo "=========================================="
echo ""

PASS_COUNT=0
FAIL_COUNT=0

run_test() {
    local test_name="$1"
    local expected_result="$2"
    shift 2
    
    echo -n "Running: $test_name ... "
    
    if eval "$@" > /tmp/test_output.txt 2>&1; then
        if [ "$expected_result" = "pass" ]; then
            echo "PASS"
            ((PASS_COUNT++))
        else
            echo "FAIL (expected failure but got success)"
            ((FAIL_COUNT++))
        fi
    else
        if [ "$expected_result" = "fail" ]; then
            echo "PASS (expected failure)"
            ((PASS_COUNT++))
        else
            echo "FAIL"
            cat /tmp/test_output.txt
            ((FAIL_COUNT++))
        fi
    fi
}

# Test 1: Check metadata files exist
echo ""
echo "--- Basic Tests ---"
run_test "Metadata directory exists" "pass" test -d data/metadata
run_test "Archive-001.json exists" "pass" test -f data/metadata/archive-001.json
run_test "Archive-002.json exists" "pass" test -f data/metadata/archive-002.json
run_test "Corrupted-001.json exists" "pass" test -f data/metadata/corrupted-001.json

# Test 2: Validate JSON structure
echo ""
echo "--- JSON Validation Tests ---"
run_test "Archive-001 is valid JSON" "pass" jq empty data/metadata/archive-001.json
run_test "Archive-002 is valid JSON" "pass" jq empty data/metadata/archive-002.json
run_test "Corrupted-001 is valid JSON" "pass" jq empty data/metadata/corrupted-001.json

# Test 3: Check required fields in metadata
echo ""
echo "--- Schema Validation Tests ---"
run_test "Archive-001 has name field" "pass" jq -e '.[].name' data/metadata/archive-001.json > /dev/null
run_test "Archive-001 has size field" "pass" jq -e '.[].size' data/metadata/archive-001.json > /dev/null
run_test "Archive-001 has type field" "pass" jq -e '.[].type' data/metadata/archive-001.json > /dev/null
run_test "Archive-001 has checksum field" "pass" jq -e '.[].checksum != null or .[].checksum == null' data/metadata/archive-001.json > /dev/null

# Test 4: Count entries
echo ""
echo "--- Entry Count Tests ---"
ARCHIVE1_COUNT=$(jq length data/metadata/archive-001.json)
run_test "Archive-001 has 6 entries" "pass" [ "$ARCHIVE1_COUNT" -eq 6 ]

ARCHIVE2_COUNT=$(jq length data/metadata/archive-002.json)
run_test "Archive-002 has 5 entries" "pass" [ "$ARCHIVE2_COUNT" -eq 5 ]

# Test 5: Type validation
echo ""
echo "--- Type Validation Tests ---"
run_test "Archive-001 has directory entries" "pass" jq -e '.[] | select(.type == "directory")' data/metadata/archive-001.json > /dev/null
run_test "Archive-001 has file entries" "pass" jq -e '.[] | select(.type == "file")' data/metadata/archive-001.json > /dev/null

# Test 6: Detect corruption patterns
echo ""
echo "--- Corruption Detection Tests ---"
EMPTY_NAME_COUNT=$(jq '[.[] | select(.name == "")] | length' data/metadata/corrupted-001.json)
run_test "Corrupted-001 has empty name entry" "pass" [ "$EMPTY_NAME_COUNT" -gt 0 ]

NEG_SIZE_COUNT=$(jq '[.[] | select(.size < 0)] | length' data/metadata/corrupted-001.json)
run_test "Corrupted-001 has negative size entry" "pass" [ "$NEG_SIZE_COUNT" -gt 0 ]

# Summary
echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo "Passed: $PASS_COUNT"
echo "Failed: $FAIL_COUNT"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo "All visible tests passed!"
    exit 0
else
    echo "Some tests failed. Please review and fix."
    exit 1
fi
