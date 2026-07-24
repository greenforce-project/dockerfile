# syntax=docker/dockerfile:1

ARG DEBIAN_VERSION=12
FROM debian:${DEBIAN_VERSION}-slim

LABEL org.opencontainers.image.title="Compiler toolchain build environment (Debian)" \
      org.opencontainers.image.description="Debian-based dependencies for building LLVM, GCC, and cross-compilation toolchains" \
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
        apt-get install -y --no-install-recommends \
            gh rclone; \
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
    command -v g++ && \
    command -v clang && \
    command -v cmake && \
    command -v meson && \
    command -v ninja && \
    command -v ccache

# GitHub Actions job-container compatibility.
#
# GitHub Actions mounts workspace and runner command directories
# when the job container starts. Actions must be able to write
# to those directories.
#
# Keep builder available for explicit local use, but use root
# as the default runtime user.
USER root
ENV HOME=/root

VOLUME ["/workspace", "/home/builder/.cache/ccache"]

CMD ["/bin/bash"]
