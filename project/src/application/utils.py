"""Utility functions for the application."""

import re


def format_message(message, prefix=""):
    """Format a message with an optional prefix.

    Args:
        message: The message to format.
        prefix: Optional prefix to add to the message.

    Returns:
        Formatted message string.
    """
    if prefix:
        return f"[{prefix}] {message}"
    return message


def validate_input(value, pattern=None, min_length=0):
    """Validate input against optional pattern and minimum length.

    Args:
        value: The value to validate.
        pattern: Optional regex pattern to match.
        min_length: Minimum required length.

    Returns:
        True if valid, False otherwise.
    """
    if not isinstance(value, str):
        return False

    if len(value) < min_length:
        return False

    if pattern is not None:
        if not re.match(pattern, value):
            return False

    return True


def sanitize_string(value):
    """Sanitize a string by removing special characters.

    Args:
        value: The string to sanitize.

    Returns:
        Sanitized string containing only alphanumeric characters and spaces.
    """
    if not isinstance(value, str):
        return ""
    return re.sub(r"[^a-zA-Z0-9\s]", "", value)
