"""Configuration management module."""

import os


class Config:
    """Application configuration class."""

    def __init__(self):
        self.app_name = os.environ.get("APP_NAME", "internal-service")
        self.debug_mode = os.environ.get("DEBUG_MODE", "false").lower() == "true"
        self.log_level = os.environ.get("LOG_LEVEL", "INFO")
        self.max_retries = int(os.environ.get("MAX_RETRIES", "3"))

    def get_settings(self):
        """Return current settings as a dictionary."""
        return {
            "app_name": self.app_name,
            "debug_mode": self.debug_mode,
            "log_level": self.log_level,
            "max_retries": self.max_retries,
        }

    def validate(self):
        """Validate the configuration."""
        if self.max_retries < 0:
            raise ValueError("max_retries must be non-negative")
        if self.log_level not in ["DEBUG", "INFO", "WARNING", "ERROR"]:
            raise ValueError(f"Invalid log level: {self.log_level}")
        return True
