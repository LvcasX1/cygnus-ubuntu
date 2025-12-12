# Cygnus-Ubuntu Test Container
# Ubuntu 24.04 base for testing installation

FROM ubuntu:24.04

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Create test user
RUN useradd -m -s /bin/bash testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install minimal requirements for testing
RUN apt-get update && apt-get install -y \
    sudo \
    curl \
    wget \
    git \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Switch to test user
USER testuser
WORKDIR /home/testuser

# Copy cygnus-ubuntu files
COPY --chown=testuser:testuser . /home/testuser/.config/cygnus-ubuntu/

# Default command
CMD ["/bin/bash"]
