#!/bin/bash

set -e

PROJECT_DIR="/workspace/task/project"

echo "Applying fixes to broken build system..."


# Fix dependency versions
cat > "${PROJECT_DIR}/requirements.txt" << 'EOF'
requests>=2.28.0
urllib3>=1.26.0,<2.0.0
botocore>=1.29.0,<1.35.0
EOF


# Fix PEP517 build configuration
cat > "${PROJECT_DIR}/pyproject.toml" << 'EOF'
[build-system]
requires = [
    "setuptools>=61.0",
    "wheel"
]
build-backend = "setuptools.build_meta"


[project]
name = "internal-service"
version = "1.0.0"
description = "Internal service for company operations"
requires-python = ">=3.10"

dependencies = [
    "requests>=2.28.0",
    "#!/bin/bash

set -e

PROJECT_DIR="/workspace/task/project"

echo "Applying fixes to broken build system..."


# Fix dependency versions
cat > "${PROJECT_DIR}/requirements.txt" << 'EOF'
requests>=2.28.0
urllib3>=1.26.0,<2.0.0
botocore>=1.29.0,<1.35.0
EOF


# Fix PEP517 build configuration
cat > "${PROJECT_DIR}/pyproject.toml" << 'EOF'
[build-system]
requires = [
    "setuptools>=61.0",
    "wheel"
]
build-backend = "setuptools.build_meta"


[project]
name = "internal-service"
version = "1.0.0"
description = "Internal service for company operations"
requires-python = ">=3.10"

dependencies = [
    "requests>=2.28.0",
    "urllib3>=1.26.0,<1.27",
    "botocore>=1.29.0,<1.35.0"
]


[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "black>=23.0.0",
    "flake8>=6.0.0"
]


[tool.setuptools.packages.find]
where = ["src"]


[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_functions = ["test_*"]
EOF


# Verify
cd "${PROJECT_DIR}"

python3.11 -m pip install -e .

python3.11 -m pytest tests/ -v


echo "Build system recovery complete!"",
    "botocore>=1.29.0,<1.35.0"
]


[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "black>=23.0.0",
    "flake8>=6.0.0"
]


[tool.setuptools.packages.find]
where = ["src"]


[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_functions = ["test_*"]
EOF


# Verify
cd "${PROJECT_DIR}"

python3.11 -m pip install -e .

python3.11 -m pytest tests/ -v


echo "Build system recovery complete!"
