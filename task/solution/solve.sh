#!/bin/bash
# Oracle solution for Broken Python Build System Recovery
# This script fixes all issues in the project configuration files

set -e

PROJECT_DIR="/workspace/task/project"

echo "Applying fixes to broken build system..."

# Fix 1: Update requirements.txt with compatible dependency versions
cat > "${PROJECT_DIR}/requirements.txt" << 'EOF'
requests>=2.28.0
urllib3>=1.26.0,<2.0.0
botocore>=1.29.0,<1.35.0
EOF

# Fix 2: Fix pyproject.toml build-system configuration
cat > "${PROJECT_DIR}/pyproject.toml" << 'EOF'
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "internal-service"
version = "1.0.0"
description = "Internal service for company operations"
requires-python = ">=3.10"
dependencies = [
    "requests>=2.28.0",
    "urllib3>=1.26.0,<2.0.0",
    "botocore>=1.29.0,<1.35.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "black>=23.0.0",
    "flake8>=6.0.0",
]

[tool.setuptools.packages.find]
where = ["src"]

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_functions = ["test_*"]
EOF

# Fix 3: Fix Dockerfile with correct Python version and build order
cat > "${PROJECT_DIR}/Dockerfile" << 'EOF'
FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
RUN pip install --no-cache-dir -e .

CMD ["python", "-m", "pytest", "tests/", "-v"]
EOF

# Fix 4: Fix CI workflow with correct Python version and modern actions
cat > "${PROJECT_DIR}/.github/workflows/ci.yml" << 'EOF'
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Python
      uses: actions/setup-python@v5
      with:
        python-version: '3.11'
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
        pip install pytest
    
    - name: Run tests
      run: |
        pytest tests/ -v
EOF

echo "All fixes applied successfully!"
echo "Verifying installation..."

cd "${PROJECT_DIR}"
python3.11 -m pip install -e . --break-system-packages --quiet
python3.11 -m pytest tests/ -v

echo "Build system recovery complete!"
