FROM haskell:9.4.8

WORKDIR /app

# Install required tools
RUN apt-get update && apt-get install -y \
    jq \
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Set up locale for deterministic behavior
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Copy project files
COPY . /app/

# Build the Haskell solution
RUN cd solution && cabal update && cabal build

# Set working directory
WORKDIR /app

# Default command
CMD ["bash"]
