"""Main application module."""

from .config import Config
from .utils import format_message, validate_input


def main():
    """Main entry point for the application."""
    config = Config()
    message = format_message("Application started", config.app_name)
    print(message)
    return 0


if __name__ == "__main__":
    exit(main())
