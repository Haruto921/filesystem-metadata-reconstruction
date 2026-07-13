"""Internal service core module."""

import requests


def fetch_data(url: str) -> dict:
    """Fetch data from a given URL.
    
    Args:
        url: The URL to fetch data from.
        
    Returns:
        A dictionary containing the response data.
        
    Raises:
        requests.RequestException: If the request fails.
    """
    response = requests.get(url, timeout=30)
    response.raise_for_status()
    return response.json()


def get_service_status() -> str:
    """Get the current service status.
    
    Returns:
        A string indicating the service is operational.
    """
    return "operational"


def calculate_sum(a: int, b: int) -> int:
    """Calculate the sum of two integers.
    
    Args:
        a: First integer.
        b: Second integer.
        
    Returns:
        The sum of a and b.
    """
    return a + b
