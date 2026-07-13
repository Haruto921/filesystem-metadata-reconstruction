"""Public tests for the broken Python build recovery task."""

import subprocess
import os
import pytest


def test_docker_build():
    """Test that docker build completes successfully.
    
    Note: This test requires Docker to be installed.
    Skip if Docker is not available in the test environment.
    """
    import shutil
    
    # Check if docker is available
    if shutil.which("docker") is None:
        pytest.skip("Docker is not installed in this environment")
        return
        
    project_dir = "/workspace/task/project"
    result = subprocess.run(
        ["docker", "build", "-t", "test-build", "."],
        cwd=project_dir,
        capture_output=True,
        text=True,
        timeout=300
    )
    assert result.returncode == 0, f"Docker build failed: {result.stderr}"


def test_package_installation():
    """Test that pip install succeeds without dependency errors."""
    project_dir = "/workspace/task/project"
    result = subprocess.run(
        ["python3", "-m", "pip", "install", "-e", ".", "--break-system-packages"],
        cwd=project_dir,
        capture_output=True,
        text=True,
        timeout=120
    )
    assert result.returncode == 0, f"pip install failed: {result.stderr}"


def test_pytest_suite():
    """Test that all existing tests pass."""
    project_dir = "/workspace/task/project"
    result = subprocess.run(
        ["python3.11", "-m", "pytest", "tests/", "-v"],
        cwd=project_dir,
        capture_output=True,
        text=True,
        timeout=120
    )
    assert result.returncode == 0, f"pytest failed: {result.stderr}\n{result.stdout}"
