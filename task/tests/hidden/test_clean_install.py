"""Hidden test: Verifies clean environment installation works."""

import subprocess
import tempfile
import os
import pytest


def test_clean_install():
    """Test that package installs in a completely fresh environment.
    
    This test verifies:
    - No undeclared dependencies exist
    - Package works outside original container context
    - All required dependencies are properly specified
    """
    with tempfile.TemporaryDirectory() as tmpdir:
        venv_path = os.path.join(tmpdir, "clean_venv")
        
        # Create fresh virtual environment (no cached packages)
        result = subprocess.run(
            ["python", "-m", "venv", venv_path],
            capture_output=True,
            text=True
        )
        assert result.returncode == 0
        
        pip_path = os.path.join(venv_path, "bin", "pip")
        python_path = os.path.join(venv_path, "bin", "python")
        
        # Upgrade pip
        subprocess.run([pip_path, "install", "--upgrade", "pip"], 
                      capture_output=True, timeout=120)
        
        # Install the package from scratch
        result = subprocess.run(
            [pip_path, "install", "."],
            cwd="/workspace/project",
            capture_output=True,
            text=True,
            timeout=300
        )
        
        assert result.returncode == 0, (
            f"Clean installation failed:\n{result.stdout}\n{result.stderr}"
        )
        
        # Verify we can import and use the package
        result = subprocess.run(
            [python_path, "-c", "from application.config import Config; c = Config(); print(c.app_name)"],
            capture_output=True,
            text=True
        )
        
        assert result.returncode == 0, (
            f"Import failed in clean environment:\n{result.stderr}"
        )
        assert "internal-service" in result.stdout
