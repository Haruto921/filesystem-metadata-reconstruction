"""Internal service package."""

__version__ = "1.0.0"

from .core import fetch_data, get_service_status, calculate_sum

__all__ = ["fetch_data", "get_service_status", "calculate_sum"]
