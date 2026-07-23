# syntax=docker/dockerfile:1

ARG UBUNTU_VERSION=24.04
FROM ubuntu:${UBUNTU_VERSION}

LABEL org.opencontainers.image.title="Android kernel build environment" \
      org.opencontainers.image.description="Ubuntu-based toolchain and dependencies for building Android/Linux kernels" \
      org.opencontainers.image.source="https://github.com/greenforce-project/dockerfile" \
      org.opencontainers.image.licenses="NOASSERTION" \
      org.opencontainers.image.vendor="greenforce-project"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG DEBIAN_FRONTEND=noninteractive
ARG USERNAME=builder
ARG USER_UID=1000
ARG USER_GID=1000
ARG INSTALL_EXTRA_TOOLS=false

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TZ=Etc/UTC \
    USE_CCACHE=1 \
    CCACHE_DIR=/home/builder/.cache/ccache \
    PATH=/home/builder/.local/bin:${PATH}

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bc \
        binutils-aarch64-linux-gnu \
        binutils-arm-linux-gnueabi \
        binutils-dev \
        bison \
        build-essential \
        ca-certificates \
        ccache \
        clang \
        cpio \
        curl \
        device-tree-compiler \
        dos2unix \
        dwarves \
        file \
        flex \
        g++-aarch64-linux-gnu \
        g++-arm-linux-gnueabi \
        gcc-aarch64-linux-gnu \
        gcc-arm-linux-gnueabi \
        git \
        git-lfs \
        jq \
        kmod \
        libelf-dev \
        libssl-dev \
        libxml2-dev \
        lld \
        llvm \
        make \
        openssh-client \
        openssl \
        python3 \
        python3-dev \
        python-is-python3 \
        rsync \
        sudo \
        tar \
        tzdata \
        wget \
        xxd \
        xz-utils \
        zip \
        zstd && \
    if [[ "${INSTALL_EXTRA_TOOLS}" == "true" ]]; then \
        apt-get install -y --no-install-recommends gh nano rclone; \
    fi && \
    groupadd --gid "${USER_GID}" "${USERNAME}" && \
    useradd --uid "${USER_UID}" --gid "${USER_GID}" --create-home --shell /bin/bash "${USERNAME}" && \
    printf '%s ALL=(ALL) NOPASSWD:ALL\n' "${USERNAME}" > "/etc/sudoers.d/${USERNAME}" && \
    chmod 0440 "/etc/sudoers.d/${USERNAME}" && \
    install -d -o "${USER_UID}" -g "${USER_GID}" /workspace "/home/${USERNAME}/.cache/ccache" && \
    rm -rf /var/lib/apt/lists/*

USER ${USERNAME}
WORKDIR /workspace

RUN git config --global init.defaultBranch main && \
    git config --global --add safe.directory /workspace && \
    command -v gcc && \
    command -v clang && \
    command -v aarch64-linux-gnu-gcc && \
    command -v arm-linux-gnueabi-gcc && \
    command -v make && \
    command -v ccache

VOLUME ["/workspace", "/home/builder/.cache/ccache"]
CMD ["/bin/bash"]
