"""Tests for the internal service core module."""

import pytest
from internal_service import get_service_status, calculate_sum


def test_get_service_status():
    """Test that the service status returns operational."""
    result = get_service_status()
    assert result == "operational"


def test_calculate_sum_positive():
    """Test calculate_sum with positive integers."""
    assert calculate_sum(2, 3) == 5
    assert calculate_sum(10, 20) == 30


def test_calculate_sum_negative():
    """Test calculate_sum with negative integers."""
    assert calculate_sum(-5, -3) == -8
    assert calculate_sum(-10, 5) == -5


def test_calculate_sum_zero():
    """Test calculate_sum with zero."""
    assert calculate_sum(0, 0) == 0
    assert calculate_sum(5, 0) == 5
    assert calculate_sum(0, 5) == 5


def test_calculate_sum_large_numbers():
    """Test calculate_sum with large numbers."""
    assert calculate_sum(1000000, 2000000) == 3000000
