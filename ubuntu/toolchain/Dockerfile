# syntax=docker/dockerfile:1

ARG UBUNTU_VERSION=24.04
FROM ubuntu:${UBUNTU_VERSION}

LABEL org.opencontainers.image.title="Compiler toolchain build environment" \
      org.opencontainers.image.description="Ubuntu-based dependencies for building LLVM, GCC, and cross-compilation toolchains" \
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
        autoconf \
        automake \
        autopoint \
        bc \
        binutils-dev \
        bison \
        build-essential \
        ca-certificates \
        ccache \
        clang \
        cmake \
        curl \
        dos2unix \
        expat \
        file \
        flex \
        g++-multilib \
        gawk \
        gcc-multilib \
        gettext \
        git \
        git-lfs \
        gnupg \
        gperf \
        help2man \
        libcap-dev \
        libelf-dev \
        libexpat1-dev \
        libgmp-dev \
        liblz4-dev \
        liblzma-dev \
        libmpc-dev \
        libmpfr-dev \
        libncurses-dev \
        libssl-dev \
        libtool \
        libxml2-dev \
        libz-dev \
        libzstd-dev \
        lld \
        llvm \
        lz4 \
        make \
        mercurial \
        meson \
        ninja-build \
        openssh-client \
        patch \
        patchelf \
        pkg-config \
        python3 \
        python3-dev \
        python-is-python3 \
        rsync \
        subversion \
        sudo \
        texinfo \
        txt2man \
        tzdata \
        u-boot-tools \
        wget \
        xxd \
        xz-utils \
        zlib1g-dev \
        zstd && \
    if [[ "${INSTALL_EXTRA_TOOLS}" == "true" ]]; then \
        apt-get install -y --no-install-recommends gh rclone; \
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
    command -v g++ && \
    command -v clang && \
    command -v cmake && \
    command -v meson && \
    command -v ninja && \
    command -v ccache

VOLUME ["/workspace", "/home/builder/.cache/ccache"]
CMD ["/bin/bash"]
