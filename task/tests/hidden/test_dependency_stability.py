"""Hidden tests for dependency stability and edge cases."""

import subprocess
import tempfile
import os
import shutil
import pytest


def test_clean_install_in_fresh_environment():
    """Test that package installs cleanly in a fresh virtual environment."""
    with tempfile.TemporaryDirectory() as tmpdir:
        venv_path = os.path.join(tmpdir, "test_venv")
        
        # Create virtual environment
        result = subprocess.run(
            ["python", "-m", "venv", venv_path],
            capture_output=True,
            text=True,
            timeout=60
        )
        assert result.returncode == 0, f"Failed to create venv: {result.stderr}"
        
        pip_path = os.path.join(venv_path, "bin", "pip")
        project_dir = "/workspace/task/project"
        
        # Install the package
        result = subprocess.run(
            [pip_path, "install", "-e", "."],
            cwd=project_dir,
            capture_output=True,
            text=True,
            timeout=120
        )
        assert result.returncode == 0, f"Clean install failed: {result.stderr}"
        
        # Verify installation
        python_path = os.path.join(venv_path, "bin", "python")
        result = subprocess.run(
            [python_path, "-c", "import internal_service; print(internal_service.get_service_status())"],
            capture_output=True,
            text=True,
            timeout=30
        )
        assert result.returncode == 0, f"Import failed: {result.stderr}"
        assert result.stdout.strip() == "operational"


def test_dependency_version_constraints():
    """Test that dependency version constraints are properly specified."""
    project_dir = "/workspace/task/project"
    
    # Read requirements.txt
    with open(os.path.join(project_dir, "requirements.txt"), "r") as f:
        requirements = f.read()
    
    # Check that urllib3 has proper version constraints
    assert "urllib3" in requirements, "urllib3 not found in requirements.txt"
    assert ">=" in requirements or "<=" in requirements or "==" in requirements or "<" in requirements or ">" in requirements, \
        "No version constraints found in requirements.txt"
    
    # Verify botocore is present with constraints
    assert "botocore" in requirements, "botocore not found in requirements.txt"


def test_regression_functional_tests():
    """Test that core functionality works after fixes."""
    # Run pytest from the task root directory where tests exist
    result = subprocess.run(
        ["python", "-m", "pytest", "/workspace/task/tests/test_core.py", "-v", "-k", "calculate_sum"],
        capture_output=True,
        text=True,
        timeout=120
    )
    assert result.returncode == 0, f"Regression tests failed: {result.stderr}\n{result.stdout}"
    
    # Verify all calculate_sum tests passed
    assert "passed" in result.stdout.lower(), "Not all regression tests passed"


def test_docker_reproducibility():
    """Test that Docker builds are reproducible.
    
    Note: This test requires Docker to be installed.
    Skip if Docker is not available in the test environment.
    """
    
    # Check if docker is available
    if shutil.which("docker") is None:
        pytest.skip("Docker is not installed in this environment")
    
    project_dir = "/workspace/task/project"
    
    # Build twice and verify both succeed
    for i in range(2):
        result = subprocess.run(
            ["docker", "build", "-t", f"test-build-{i}", "."],
            cwd=project_dir,
            capture_output=True,
            text=True,
            timeout=300
        )
        assert result.returncode == 0, f"Docker build {i} failed: {result.stderr}"


def test_no_hardcoded_paths():
    """Test that configuration files don't contain hardcoded machine-specific paths."""
    project_dir = "/workspace/task/project"
    config_files = ["pyproject.toml", "Dockerfile", ".github/workflows/ci.yml"]
    
    for config_file in config_files:
        filepath = os.path.join(project_dir, config_file)
        if os.path.exists(filepath):
            with open(filepath, "r") as f:
                content = f.read()
            
            # Check for common hardcoded path patterns
            assert "/home/" not in content or "/home/ubuntu" not in content, \
                f"Hardcoded home path found in {config_file}"
            assert "/Users/" not in content, \
                f"MacOS user path found in {config_file}"
            assert "C:\\" not in content, \
                f"Windows path found in {config_file}"
