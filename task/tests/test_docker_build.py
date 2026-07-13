"""Public test: Verifies docker build succeeds from project directory."""

import subprocess
import pytest


def test_docker_build():
    """Test that docker build . succeeds from the project directory.
    
    This test verifies:
    - Dockerfile is valid and builds successfully
    - No dependency resolver errors occur
    - Image is created successfully
    """
    result = subprocess.run(
        ["docker", "build", "-t", "test-project-build", "."],
        cwd="/workspace/project",
        capture_output=True,
        text=True,
        timeout=300
    )
    
    assert result.returncode == 0, f"Docker build failed:\nSTDOUT: {result.stdout}\nSTDERR: {result.stderr}"
    
    # Verify image was created
    inspect_result = subprocess.run(
        ["docker", "image", "inspect", "test-project-build"],
        capture_output=True,
        text=True
    )
    
    assert inspect_result.returncode == 0, "Docker image was not created successfully"
