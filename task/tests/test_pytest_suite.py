"""Public test: Verifies the existing test suite passes."""

import subprocess
import pytest


def test_pytest_suite():
    """Test that all visible tests in the project pass.
    
    This test verifies:
    - All test files can be discovered
    - All tests execute without errors
    - No test failures occur
    """
    result = subprocess.run(
        ["python", "-m", "pytest", "tests/", "-v"],
        cwd="/workspace/project",
        capture_output=True,
        text=True,
        timeout=120
    )
    
    assert result.returncode == 0, (
        f"Pytest suite failed:\nSTDOUT: {result.stdout}\nSTDERR: {result.stderr}"
    )
    
    # Verify some tests actually ran
    assert "passed" in result.stdout, "No tests appear to have passed"
