# Use Ubuntu 22.04 as base image for consistency with GitHub Actions
FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Enable arm64 architecture for multi-arch packages first
RUN dpkg --add-architecture arm64

# Install basic dependencies and cross-compilation toolchain
RUN apt-get update && apt-get install -y \
    # Build essentials
    build-essential \
    cmake \
    ninja-build \
    git \
    wget \
    curl \
    ccache \
    pkg-config \
    # Cross-compilation toolchain for aarch64
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
    binutils-aarch64-linux-gnu \
    # QLC+ dependencies (host architecture versions for build tools)
    python3 \
    python3-pip \
    python3-lxml \
    libxml2-utils \
    # Additional utilities
    vim \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install QLC+ dependencies for aarch64 (cross-compiled)
RUN apt-get update && apt-get install -y \
    libasound2-dev:arm64 \
    libusb-1.0-0-dev:arm64 \
    libftdi1-dev:arm64 \
    libudev-dev:arm64 \
    libmad0-dev:arm64 \
    libsndfile1-dev:arm64 \
    liblo-dev:arm64 \
    libfftw3-dev:arm64 \
    libgl1-mesa-dev:arm64 \
    && rm -rf /var/lib/apt/lists/*

# Set up ccache
ENV PATH="/usr/lib/ccache:${PATH}"
ENV CCACHE_DIR="/workspace/.ccache"
ENV CCACHE_MAXSIZE="2G"

# Set up cross-compilation environment variables
ENV CROSS_COMPILE=aarch64-linux-gnu-
ENV CC=aarch64-linux-gnu-gcc
ENV CXX=aarch64-linux-gnu-g++
ENV AR=aarch64-linux-gnu-ar
ENV AS=aarch64-linux-gnu-as
ENV LD=aarch64-linux-gnu-ld
ENV RANLIB=aarch64-linux-gnu-ranlib
ENV STRIP=aarch64-linux-gnu-strip

# Create a non-root user
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Set the default user
USER $USERNAME

# Set working directory
WORKDIR /workspace

CMD ["/bin/bash"]
