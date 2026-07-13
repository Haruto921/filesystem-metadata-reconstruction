"""Hidden test: Verifies dependency stability and version constraints."""

import subprocess
import tempfile
import os
import re
import pytest


def test_dependency_stability():
    """Test that resolved dependency versions are stable and compatible.
    
    This test verifies:
    - urllib3 version is compatible with all dependencies
    - No uncontrolled dependency upgrades occur
    - Version constraints are properly satisfied
    """
    with tempfile.TemporaryDirectory() as tmpdir:
        venv_path = os.path.join(tmpdir, "stability_venv")
        
        # Create virtual environment
        subprocess.run(["python", "-m", "venv", venv_path], 
                      capture_output=True)
        
        pip_path = os.path.join(venv_path, "bin", "pip")
        
        # Upgrade pip
        subprocess.run([pip_path, "install", "--upgrade", "pip"], 
                      capture_output=True, timeout=120)
        
        # Install the package
        result = subprocess.run(
            [pip_path, "install", "."],
            cwd="/workspace/project",
            capture_output=True,
            text=True,
            timeout=300
        )
        
        assert result.returncode == 0, f"Installation failed: {result.stderr}"
        
        # Get installed packages
        result = subprocess.run(
            [pip_path, "freeze"],
            capture_output=True,
            text=True
        )
        
        assert result.returncode == 0
        
        # Parse installed versions
        packages = {}
        for line in result.stdout.strip().split('\n'):
            if '==' in line:
                name, version = line.split('==')
                packages[name.lower()] = version
        
        # Verify urllib3 is installed and has a valid version
        assert 'urllib3' in packages, "urllib3 not found in installed packages"
        
        urllib3_version = packages['urllib3']
        version_parts = urllib3_version.split('.')
        major_version = int(version_parts[0])
        
        # urllib3 should be either 1.x or 2.x but compatible with all deps
        assert major_version in [1, 2], f"Unexpected urllib3 major version: {major_version}"
        
        # Verify requests is installed
        assert 'requests' in packages, "requests not found in installed packages"
        
        # Verify no conflict errors in installation output
        assert "ResolutionImpossible" not in result.stderr
        assert "conflict" not in result.stderr.lower()
