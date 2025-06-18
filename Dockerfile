FROM ubuntu:22.04

# Disable prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    openssh-client \
    sshpass \
    sudo \
    python3 \
    python3-pip \
    curl \
    git \
    vim \
    iputils-ping \
    net-tools \
    software-properties-common && \
    pip3 install ansible && \
    mkdir -p /var/run/sshd && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Keep container running to allow manual configuration
CMD ["/bin/bash", "-c", "tail -f /dev/null"]
