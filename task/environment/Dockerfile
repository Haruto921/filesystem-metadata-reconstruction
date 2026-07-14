FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*


RUN python -m pip install --no-cache-dir \
    pip==24.0 \
    setuptools==69.0.3 \
    wheel==0.42.0 \
    build==1.0.3 \
    pip-tools==7.3.0 \
    pytest==8.0.0


WORKDIR /workspace/task/project


COPY project .


RUN python -m pip install --no-cache-dir -e .


CMD ["sleep", "infinity"]
