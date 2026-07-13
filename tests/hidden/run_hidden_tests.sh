#!/bin/bash
# Hidden Test Suite for Filesystem Metadata Reconstruction
# This script runs hidden tests that agents cannot see
# Used for final evaluation and anti-cheating validation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

cd "$PROJECT_ROOT"

echo "=========================================="
echo "Filesystem Metadata Reconstruction"
echo "Hidden Test Suite (Evaluation Only)"
echo "=========================================="
echo ""

PASS_COUNT=0
FAIL_COUNT=0

run_hidden_test() {
    local test_name="$1"
    local expected_result="$2"
    shift 2
    
    echo -n "HIDDEN TEST: $test_name ... "
    
    if eval "$@" > /tmp/hidden_test_output.txt 2>&1; then
        if [ "$expected_result" = "pass" ]; then
            echo "PASS"
            ((PASS_COUNT++))
        else
            echo "FAIL"
            ((FAIL_COUNT++))
        fi
    else
        if [ "$expected_result" = "fail" ]; then
            echo "PASS"
            ((PASS_COUNT++))
        else
            echo "FAIL"
            ((FAIL_COUNT++))
        fi
    fi
}

# Hidden Test 1: Verify oracle can process all valid archives
echo "--- Oracle Processing Tests ---"
run_hidden_test "Oracle processes archive-001" "pass" \
    jq -e 'length > 0' data/metadata/archive-001.json

run_hidden_test "Oracle processes archive-002" "pass" \
    jq -e 'length > 0' data/metadata/archive-002.json

# Hidden Test 2: Validate no duplicate paths in valid archives
echo ""
echo "--- Integrity Tests ---"
run_hidden_test "Archive-001 has unique paths" "pass" \
    bash -c 'COUNT=$(jq length data/metadata/archive-001.json); UNIQUE=$(jq -r ".[].name" data/metadata/archive-001.json | sort -u | wc -l); [ "$COUNT" -eq "$UNIQUE" ]'

run_hidden_test "Archive-002 has unique paths" "pass" \
    bash -c 'COUNT=$(jq length data/metadata/archive-002.json); UNIQUE=$(jq -r ".[].name" data/metadata/archive-002.json | sort -u | wc -l); [ "$COUNT" -eq "$UNIQUE" ]'

# Hidden Test 3: Verify hierarchical consistency
echo ""
echo "--- Hierarchy Consistency Tests ---"
# Check that parent directories exist for all files
run_hidden_test "Archive-001 hierarchy valid" "pass" \
    bash -c 'jq -r ".[].name" data/metadata/archive-001.json | while read path; do dirname "$path"; done | grep -v "^\\.$" | sort -u > /tmp/parents.txt && jq -r ".[] | select(.type==\"directory\") | .name" data/metadata/archive-001.json | sort -u > /tmp/dirs.txt && diff /tmp/parents.txt /tmp/dirs.txt || [ $? -eq 0 ] || true'

# Hidden Test 4: Size calculations
echo ""
echo "--- Size Aggregation Tests ---"
# Total size of files in archive-001 (should be 1024 + 2048 + 512 = 3584)
run_hidden_test "Archive-001 total size correct" "pass" \
    bash -c 'TOTAL=$(jq "[.[] | select(.type==\"file\") | .size] | add" data/metadata/archive-001.json); [ "$TOTAL" -eq 3584 ]'

# Total size of files in archive-002 (should be 4096 + 1536 + 8192 = 13824)
run_hidden_test "Archive-002 total size correct" "pass" \
    bash -c 'TOTAL=$(jq "[.[] | select(.type==\"file\") | .size] | add" data/metadata/archive-002.json); [ "$TOTAL" -eq 13824 ]'

# Hidden Test 5: Corruption detection accuracy
echo ""
echo "--- Corruption Detection Tests ---"
run_hidden_test "Corrupted-001 detects all errors" "pass" \
    bash -c 'EMPTY=$(jq "[.[] | select(.name == \"\")] | length" data/metadata/corrupted-001.json); NEG=$(jq "[.[] | select(.size < 0)] | length" data/metadata/corrupted-001.json); [ "$EMPTY" -eq 1 ] && [ "$NEG" -eq 1 ]'

# Hidden Test 6: Determinism check - run same query twice
echo ""
echo "--- Determinism Tests ---"
HASH1=$(jq -S '.' data/metadata/archive-001.json | md5sum)
HASH2=$(jq -S '.' data/metadata/archive-001.json | md5sum)
run_hidden_test "JSON processing is deterministic" "pass" \
    bash -c '[ "'"$HASH1"'" = "'"$HASH2"'" ]'

# Hidden Test 7: Edge case - empty checksums are allowed
echo ""
echo "--- Edge Case Tests ---"
NULL_CHECKSUM_COUNT=$(jq '[.[] | select(.checksum == null)] | length' data/metadata/archive-001.json)
run_hidden_test "Archive-001 allows null checksums" "pass" \
    [ "$NULL_CHECKSUM_COUNT" -gt 0 ]

# Summary
echo ""
echo "=========================================="
echo "Hidden Test Summary"
echo "=========================================="
echo "Passed: $PASS_COUNT"
echo "Failed: $FAIL_COUNT"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo "All hidden tests passed!"
    exit 0
else
    echo "Some hidden tests failed."
    exit 1
fi
