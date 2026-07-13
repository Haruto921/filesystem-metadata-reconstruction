"""Tests for the configuration module."""

import os
import pytest
from application.config import Config


class TestConfigDefaults:
    """Tests for default configuration values."""

    def test_default_app_name(self, monkeypatch):
        """Test default app name when env var is not set."""
        monkeypatch.delenv("APP_NAME", raising=False)
        config = Config()
        assert config.app_name == "internal-service"

    def test_default_debug_mode(self, monkeypatch):
        """Test default debug mode is False."""
        monkeypatch.delenv("DEBUG_MODE", raising=False)
        config = Config()
        assert config.debug_mode is False

    def test_default_log_level(self, monkeypatch):
        """Test default log level is INFO."""
        monkeypatch.delenv("LOG_LEVEL", raising=False)
        config = Config()
        assert config.log_level == "INFO"

    def test_default_max_retries(self, monkeypatch):
        """Test default max retries is 3."""
        monkeypatch.delenv("MAX_RETRIES", raising=False)
        config = Config()
        assert config.max_retries == 3


class TestConfigEnvironmentVariables:
    """Tests for configuration from environment variables."""

    def test_custom_app_name(self, monkeypatch):
        """Test custom app name from environment."""
        monkeypatch.setenv("APP_NAME", "my-custom-app")
        config = Config()
        assert config.app_name == "my-custom-app"

    def test_debug_mode_enabled(self, monkeypatch):
        """Test debug mode enabled from environment."""
        monkeypatch.setenv("DEBUG_MODE", "true")
        config = Config()
        assert config.debug_mode is True

    def test_debug_mode_disabled(self, monkeypatch):
        """Test debug mode disabled from environment."""
        monkeypatch.setenv("DEBUG_MODE", "false")
        config = Config()
        assert config.debug_mode is False

    def test_custom_log_level(self, monkeypatch):
        """Test custom log level from environment."""
        monkeypatch.setenv("LOG_LEVEL", "DEBUG")
        config = Config()
        assert config.log_level == "DEBUG"

    def test_custom_max_retries(self, monkeypatch):
        """Test custom max retries from environment."""
        monkeypatch.setenv("MAX_RETRIES", "10")
        config = Config()
        assert config.max_retries == 10


class TestConfigGetSettings:
    """Tests for get_settings method."""

    def test_get_settings_returns_dict(self, monkeypatch):
        """Test that get_settings returns a dictionary."""
        monkeypatch.delenv("APP_NAME", raising=False)
        monkeypatch.delenv("DEBUG_MODE", raising=False)
        monkeypatch.delenv("LOG_LEVEL", raising=False)
        monkeypatch.delenv("MAX_RETRIES", raising=False)
        config = Config()
        settings = config.get_settings()
        assert isinstance(settings, dict)

    def test_get_settings_contains_all_keys(self, monkeypatch):
        """Test that get_settings contains all expected keys."""
        monkeypatch.delenv("APP_NAME", raising=False)
        monkeypatch.delenv("DEBUG_MODE", raising=False)
        monkeypatch.delenv("LOG_LEVEL", raising=False)
        monkeypatch.delenv("MAX_RETRIES", raising=False)
        config = Config()
        settings = config.get_settings()
        assert "app_name" in settings
        assert "debug_mode" in settings
        assert "log_level" in settings
        assert "max_retries" in settings


class TestConfigValidate:
    """Tests for validate method."""

    def test_validate_default_config(self, monkeypatch):
        """Test validation of default configuration."""
        monkeypatch.delenv("APP_NAME", raising=False)
        monkeypatch.delenv("DEBUG_MODE", raising=False)
        monkeypatch.delenv("LOG_LEVEL", raising=False)
        monkeypatch.delenv("MAX_RETRIES", raising=False)
        config = Config()
        assert config.validate() is True

    def test_validate_invalid_log_level(self, monkeypatch):
        """Test validation fails with invalid log level."""
        monkeypatch.setenv("LOG_LEVEL", "INVALID")
        config = Config()
        with pytest.raises(ValueError):
            config.validate()

    def test_validate_negative_max_retries(self, monkeypatch):
        """Test validation fails with negative max retries."""
        monkeypatch.setenv("MAX_RETRIES", "-1")
        config = Config()
        with pytest.raises(ValueError):
            config.validate()
