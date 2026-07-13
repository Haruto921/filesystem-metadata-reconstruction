"""Tests for the core application functionality."""

import pytest
from application.main import main
from application.utils import format_message, validate_input, sanitize_string


class TestFormatMessage:
    """Tests for format_message function."""

    def test_format_with_prefix(self):
        """Test formatting a message with a prefix."""
        result = format_message("Hello", "Test")
        assert result == "[Test] Hello"

    def test_format_without_prefix(self):
        """Test formatting a message without a prefix."""
        result = format_message("Hello")
        assert result == "Hello"

    def test_format_empty_message(self):
        """Test formatting an empty message."""
        result = format_message("")
        assert result == ""

    def test_format_empty_prefix(self):
        """Test formatting with an empty prefix."""
        result = format_message("Hello", "")
        assert result == "Hello"


class TestValidateInput:
    """Tests for validate_input function."""

    def test_valid_string(self):
        """Test validating a valid string."""
        assert validate_input("hello") is True

    def test_invalid_type(self):
        """Test validating non-string input."""
        assert validate_input(123) is False
        assert validate_input(None) is False

    def test_min_length_pass(self):
        """Test validation with min_length that passes."""
        assert validate_input("hello", min_length=3) is True

    def test_min_length_fail(self):
        """Test validation with min_length that fails."""
        assert validate_input("hi", min_length=5) is False

    def test_pattern_match(self):
        """Test validation with a matching pattern."""
        assert validate_input("abc123", pattern=r"^[a-z0-9]+$") is True

    def test_pattern_no_match(self):
        """Test validation with a non-matching pattern."""
        assert validate_input("ABC", pattern=r"^[a-z]+$") is False


class TestSanitizeString:
    """Tests for sanitize_string function."""

    def test_sanitize_removes_special_chars(self):
        """Test that special characters are removed."""
        result = sanitize_string("hello@world!")
        assert result == "helloworld"

    def test_sanitize_keeps_alphanumeric(self):
        """Test that alphanumeric characters are kept."""
        result = sanitize_string("abc123")
        assert result == "abc123"

    def test_sanitize_keeps_spaces(self):
        """Test that spaces are kept."""
        result = sanitize_string("hello world")
        assert result == "hello world"

    def test_sanitize_non_string(self):
        """Test sanitizing non-string input."""
        result = sanitize_string(123)
        assert result == ""


class TestMain:
    """Tests for the main function."""

    def test_main_returns_zero(self, monkeypatch):
        """Test that main returns 0 on success."""
        # Mock print to avoid output
        monkeypatch.setattr("builtins.print", lambda *args: None)
        result = main()
        assert result == 0
