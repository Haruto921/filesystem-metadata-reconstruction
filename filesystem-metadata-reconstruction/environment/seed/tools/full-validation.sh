#!/bin/bash
# Run all validation checks

SCRIPT_DIR="$(dirname "$0")"
FAILED=0

echo "=== Running Full Validation ==="
echo

"$SCRIPT_DIR/validate-schema.sh" || FAILED=1
"$SCRIPT_DIR/check-integrity.sh" || FAILED=1
"$SCRIPT_DIR/verify-checksums.sh" || FAILED=1

echo
if [ "$FAILED" -eq 0 ]; then
    echo "=== ALL VALIDATIONS PASSED ==="
    exit 0
else
    echo "=== VALIDATION FAILED ==="
    exit 1
fi
