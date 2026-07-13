FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.11 \
    python3-pip \
    python3-venv \
    python3.11-venv \
    python3.11-dev \
    git \
    gcc \
    make \
    curl \
    grep \
    sed \
    tree \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.11 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1 \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Upgrade pip and install Python tools
RUN python -m pip install --upgrade pip \
    && pip install pytest==8.0.0 build==1.0.3 pip-tools==7.3.0 setuptools==69.0.3 wheel==0.42.0

# Set working directory
WORKDIR /workspace

# Copy project files
COPY project/ /workspace/project/

# Set default command
CMD ["/bin/bash"]
