FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PYTHON_VERSION=3.11

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    build-essential \
    python3.11 \
    python3.11-venv \
    python3.11-dev \
    python3-pip \
    ca-certificates \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11

RUN python3.11 -m pip install --no-cache-dir \
    pip==24.0 \
    setuptools==69.0.3 \
    wheel==0.42.0 \
    build==1.0.3 \
    pip-tools==7.3.0 \
    pytest==8.0.0

WORKDIR /workspace/task/project

COPY . .

RUN python3.11 -m pip install --no-cache-dir -e .

CMD ["pytest", "tests/", "-v"]
