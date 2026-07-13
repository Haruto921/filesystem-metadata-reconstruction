"""Hidden test: Functional regression tests for the application."""

import subprocess
import tempfile
import os
import pytest


def test_application_imports():
    """Test that all application modules can be imported correctly."""
    with tempfile.TemporaryDirectory() as tmpdir:
        venv_path = os.path.join(tmpdir, "regression_venv")
        
        # Create virtual environment
        subprocess.run(["python", "-m", "venv", venv_path], 
                      capture_output=True)
        
        pip_path = os.path.join(venv_path, "bin", "pip")
        python_path = os.path.join(venv_path, "bin", "python")
        
        # Upgrade pip and install package
        subprocess.run([pip_path, "install", "--upgrade", "pip"], 
                      capture_output=True, timeout=120)
        
        result = subprocess.run(
            [pip_path, "install", "."],
            cwd="/workspace/project",
            capture_output=True,
            text=True,
            timeout=300
        )
        assert result.returncode == 0, f"Installation failed: {result.stderr}"
        
        # Test imports
        imports_to_test = [
            "from application import __version__",
            "from application.main import main",
            "from application.config import Config",
            "from application.utils import format_message, validate_input, sanitize_string",
        ]
        
        for import_stmt in imports_to_test:
            result = subprocess.run(
                [python_path, "-c", import_stmt],
                capture_output=True,
                text=True
            )
            assert result.returncode == 0, (
                f"Import failed: {import_stmt}\nSTDERR: {result.stderr}"
            )


def test_config_functionality():
    """Test configuration loading and validation."""
    with tempfile.TemporaryDirectory() as tmpdir:
        venv_path = os.path.join(tmpdir, "config_venv")
        
        subprocess.run(["python", "-m", "venv", venv_path], capture_output=True)
        
        pip_path = os.path.join(venv_path, "bin", "pip")
        python_path = os.path.join(venv_path, "bin", "python")
        
        subprocess.run([pip_path, "install", "--upgrade", "pip"], 
                      capture_output=True, timeout=120)
        subprocess.run([pip_path, "install", "."], cwd="/workspace/project",
                      capture_output=True, timeout=300)
        
        # Test config functionality
        test_code = """
from application.config import Config
import os

# Test default values
os.environ.pop('APP_NAME', None)
os.environ.pop('DEBUG_MODE', None)
os.environ.pop('LOG_LEVEL', None)
os.environ.pop('MAX_RETRIES', None)

c = Config()
assert c.app_name == 'internal-service', f"Expected 'internal-service', got '{c.app_name}'"
assert c.debug_mode is False
assert c.log_level == 'INFO'
assert c.max_retries == 3

# Test get_settings
settings = c.get_settings()
assert isinstance(settings, dict)
assert 'app_name' in settings

# Test validation
assert c.validate() is True

print("Config tests passed")
"""
        result = subprocess.run(
            [python_path, "-c", test_code],
            capture_output=True,
            text=True
        )
        assert result.returncode == 0, (
            f"Config functionality test failed:\n{result.stderr}"
        )


def test_utils_functionality():
    """Test utility functions work correctly."""
    with tempfile.TemporaryDirectory() as tmpdir:
        venv_path = os.path.join(tmpdir, "utils_venv")
        
        subprocess.run(["python", "-m", "venv", venv_path], capture_output=True)
        
        pip_path = os.path.join(venv_path, "bin", "pip")
        python_path = os.path.join(venv_path, "bin", "python")
        
        subprocess.run([pip_path, "install", "--upgrade", "pip"], 
                      capture_output=True, timeout=120)
        subprocess.run([pip_path, "install", "."], cwd="/workspace/project",
                      capture_output=True, timeout=300)
        
        test_code = """
from application.utils import format_message, validate_input, sanitize_string

# Test format_message
assert format_message("Hello", "Test") == "[Test] Hello"
assert format_message("Hello") == "Hello"

# Test validate_input
assert validate_input("hello") is True
assert validate_input(123) is False
assert validate_input("hi", min_length=5) is False
assert validate_input("abc123", pattern=r'^[a-z0-9]+$') is True

# Test sanitize_string
assert sanitize_string("hello@world!") == "helloworld"
assert sanitize_string("abc123") == "abc123"
assert sanitize_string(123) == ""

print("Utils tests passed")
"""
        result = subprocess.run(
            [python_path, "-c", test_code],
            capture_output=True,
            text=True
        )
        assert result.returncode == 0, (
            f"Utils functionality test failed:\n{result.stderr}"
        )
