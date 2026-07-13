"""Public test: Verifies pip install . works in a clean virtual environment."""

import subprocess
import tempfile
import os
import pytest


def test_package_installation():
    """Test that pip install . succeeds in a clean virtual environment.
    
    This test verifies:
    - Package metadata is valid
    - All dependencies resolve without conflict
    - Installation completes successfully
    """
    with tempfile.TemporaryDirectory() as tmpdir:
        venv_path = os.path.join(tmpdir, "test_venv")
        
        # Create virtual environment
        result = subprocess.run(
            ["python", "-m", "venv", venv_path],
            capture_output=True,
            text=True
        )
        assert result.returncode == 0, f"Failed to create venv: {result.stderr}"
        
        # Get pip path in venv
        pip_path = os.path.join(venv_path, "bin", "pip")
        
        # Upgrade pip first
        result = subprocess.run(
            [pip_path, "install", "--upgrade", "pip"],
            capture_output=True,
            text=True,
            timeout=120
        )
        assert result.returncode == 0, f"Failed to upgrade pip: {result.stderr}"
        
        # Install the package
        result = subprocess.run(
            [pip_path, "install", "."],
            cwd="/workspace/project",
            capture_output=True,
            text=True,
            timeout=300
        )
        
        assert result.returncode == 0, (
            f"Package installation failed:\nSTDOUT: {result.stdout}\nSTDERR: {result.stderr}"
        )
        
        # Verify package is installed
        result = subprocess.run(
            [pip_path, "show", "internal-service"],
            capture_output=True,
            text=True
        )
        
        assert result.returncode == 0, "Package 'internal-service' was not installed successfully"
