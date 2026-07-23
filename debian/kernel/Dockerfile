# syntax=docker/dockerfile:1

ARG DEBIAN_VERSION=12
FROM debian:${DEBIAN_VERSION}-slim

LABEL org.opencontainers.image.title="Android kernel build environment (Debian)" \
      org.opencontainers.image.description="Debian-based dependencies for building Android and Linux kernels" \
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
    HOME=/home/${USERNAME} \
    CCACHE_DIR=/home/${USERNAME}/.cache/ccache \
    PATH=/home/${USERNAME}/.local/bin:${PATH}

COPY --chmod=0755 scripts/create-builder-user.sh \
    /usr/local/bin/create-builder-user

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
        apt-get install -y --no-install-recommends \
            gh nano rclone; \
    fi && \
    rm -rf /var/lib/apt/lists/* && \
    create-builder-user && \
    rm -f /usr/local/bin/create-builder-user

USER ${USERNAME}
WORKDIR /workspace

RUN test "$(id -u)" = "${USER_UID}" && \
    test "$(id -g)" = "${USER_GID}" && \
    test -w "${HOME}" && \
    git config --global init.defaultBranch main && \
    git config --global --add safe.directory /workspace && \
    command -v gcc && \
    command -v clang && \
    command -v aarch64-linux-gnu-gcc && \
    command -v arm-linux-gnueabi-gcc && \
    command -v make && \
    command -v ccache

VOLUME ["/workspace", "/home/builder/.cache/ccache"]

CMD ["/bin/bash"]
