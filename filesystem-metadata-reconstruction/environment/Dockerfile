FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    jq \
    coreutils \
    findutils \
    grep \
    sed \
    sha256sum \
    python3 \
    python3-minimal \
    && rm -rf /var/lib/apt/lists/*

# Create workspace layout
RUN mkdir -p /workspace/{archive,metadata,reports,tools,logs,tmp}

# Create non-root user for execution
RUN useradd -m -s /bin/bash benchmark \
    && chown -R benchmark:benchmark /workspace

# Copy seed data and tools
COPY --chown=benchmark:benchmark environment/seed/archive/ /workspace/archive/
COPY --chown=benchmark:benchmark environment/seed/metadata/ /workspace/metadata/
COPY --chown=benchmark:benchmark environment/seed/tools/ /workspace/tools/

# Make tools executable
RUN chmod +x /workspace/tools/*.sh 2>/dev/null || true

# Set working directory
WORKDIR /workspace

# Switch to non-root user
USER benchmark

# Default command
CMD ["/bin/bash"]
