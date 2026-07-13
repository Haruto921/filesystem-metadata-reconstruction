#!/bin/bash
# Build script for the application
set -e

echo "Building application..."
python -m build

echo "Build complete!"
