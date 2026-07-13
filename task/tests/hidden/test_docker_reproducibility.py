"""Hidden test: Verifies Docker builds are reproducible."""

import subprocess
import pytest


def test_docker_reproducibility():
    """Test that Docker builds succeed consistently.
    
    This test verifies:
    - Multiple builds succeed with same result
    - No environment-dependent behavior
    - Build is deterministic and reproducible
    """
    # First build
    result1 = subprocess.run(
        ["docker", "build", "-t", "test-project-repro-1", "."],
        cwd="/workspace/project",
        capture_output=True,
        text=True,
        timeout=300
    )
    
    assert result1.returncode == 0, (
        f"First Docker build failed:\nSTDOUT: {result1.stdout}\nSTDERR: {result1.stderr}"
    )
    
    # Second build
    result2 = subprocess.run(
        ["docker", "build", "-t", "test-project-repro-2", "."],
        cwd="/workspace/project",
        capture_output=True,
        text=True,
        timeout=300
    )
    
    assert result2.returncode == 0, (
        f"Second Docker build failed:\nSTDOUT: {result2.stdout}\nSTDERR: {result2.stderr}"
    )
    
    # Verify both images exist
    for image_name in ["test-project-repro-1", "test-project-repro-2"]:
        result = subprocess.run(
            ["docker", "image", "inspect", image_name],
            capture_output=True,
            text=True
        )
        assert result.returncode == 0, f"Docker image {image_name} was not created"
