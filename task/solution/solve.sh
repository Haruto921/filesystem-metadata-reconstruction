#!/bin/bash
# Oracle solution script for Broken Python Build System Recovery
# This script applies minimal fixes to restore the build system

set -e

echo "=== Oracle Solution: Broken Python Build System Recovery ==="
echo ""

PROJECT_DIR="/workspace/project"
cd "$PROJECT_DIR"

echo "Step 1: Fixing requirements.txt..."
# Fix dependency conflict by using compatible versions
# The issue is that botocore 1.34.0 requires urllib3>=1.25.4,<2.1
# We need to pin urllib3 to a version < 2 that works with all dependencies
cat > requirements.txt << 'EOF'
requests==2.31.0
urllib3>=1.26.0,<2.0.0
botocore>=1.29.0,<1.35.0
EOF
echo "✓ requirements.txt fixed"

echo ""
echo "Step 2: Fixing pyproject.toml..."
# Fix build-system configuration with valid backend and modern setuptools
cat > pyproject.toml << 'EOF'
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "internal-service"
version = "1.0.0"
description = "Internal Python service"
requires-python = ">=3.11"
license = { text = "MIT" }
authors = [
    { name = "Engineering Team", email = "engineering@example.com" }
]
dependencies = [
    "requests>=2.28.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "black",
]

[tool.setuptools.packages.find]
where = ["src"]

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
EOF
echo "✓ pyproject.toml fixed"

echo ""
echo "Step 3: Fixing Dockerfile..."
# Fix Dockerfile with correct Python version, proper WORKDIR, and correct build order
cat > Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies first
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    make \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better layer caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Install the package
RUN pip install --no-cache-dir -e .

EXPOSE 8080

CMD ["python", "-m", "application.main"]
EOF
echo "✓ Dockerfile fixed"

echo ""
echo "Step 4: Fixing .github/workflows/ci.yml..."
# Fix CI configuration with correct Python version and updated actions
cat > .github/workflows/ci.yml << 'EOF'
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        python-version: ["3.11"]
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Python ${{ matrix.python-version }}
      uses: actions/setup-python@v5
      with:
        python-version: ${{ matrix.python-version }}
        cache: 'pip'
        cache-dependency-path: requirements.txt
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
        pip install -e .
    
    - name: Run tests
      run: |
        pytest tests/ -v
    
    - name: Build package
      run: |
        python -m build
EOF
echo "✓ ci.yml fixed"

echo ""
echo "=== All fixes applied successfully ==="
echo ""
echo "Validation commands:"
echo "  cd $PROJECT_DIR"
echo "  docker build ."
echo "  pip install ."
echo "  pytest tests/"
