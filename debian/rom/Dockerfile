# syntax=docker/dockerfile:1

ARG DEBIAN_VERSION=12
FROM debian:${DEBIAN_VERSION}-slim

LABEL org.opencontainers.image.title="Android ROM build environment (Debian)" \
      org.opencontainers.image.description="Debian-based dependencies for building AOSP and custom Android ROMs" \
      org.opencontainers.image.source="https://github.com/greenforce-project/dockerfile" \
      org.opencontainers.image.licenses="NOASSERTION" \
      org.opencontainers.image.vendor="greenforce-project"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG DEBIAN_FRONTEND=noninteractive
ARG USERNAME=builder
ARG USER_UID=1000
ARG USER_GID=1000
ARG INSTALL_LEGACY_JDKS=false
ARG INSTALL_EXTRA_TOOLS=false

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    TZ=Etc/UTC \
    JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 \
    JAVA_OPTS=-Xmx7G \
    USE_CCACHE=1 \
    HOME=/home/${USERNAME} \
    CCACHE_DIR=/home/${USERNAME}/.cache/ccache \
    PATH=/home/${USERNAME}/.local/bin:${PATH}

COPY --chmod=0755 scripts/create-builder-user.sh \
    /usr/local/bin/create-builder-user

RUN if [[ "${INSTALL_LEGACY_JDKS}" == "true" ]]; then \
        printf '%s\n' \
            'Debian 12 supports OpenJDK 17 in this image.' \
            'Use the Ubuntu ROM image for bundled Java 8 and Java 11.' >&2; \
        exit 2; \
    fi && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        adb \
        aria2 \
        autoconf \
        automake \
        axel \
        bc \
        bison \
        build-essential \
        ca-certificates \
        ca-certificates-java \
        ccache \
        clang \
        cmake \
        curl \
        dos2unix \
        expat \
        fastboot \
        ffmpeg \
        flex \
        g++ \
        g++-multilib \
        gawk \
        gcc \
        gcc-multilib \
        gh \
        git \
        git-lfs \
        gnupg \
        gperf \
        imagemagick \
        jq \
        libcap-dev \
        libexpat1-dev \
        libgmp-dev \
        liblz4-dev \
        libmpc-dev \
        libmpfr-dev \
        libncurses-dev \
        libssl-dev \
        libtool \
        libxml-simple-perl \
        libxml2-dev \
        libxml2-utils \
        libzstd-dev \
        locales \
        lzip \
        lz4 \
        lzop \
        make \
        maven \
        nano \
        openjdk-17-jdk-headless \
        openssh-client \
        openssl \
        p7zip-full \
        patch \
        patchelf \
        pigz \
        pixz \
        pkg-config \
        pngcrush \
        pngquant \
        python3 \
        python3-dev \
        python-is-python3 \
        rclone \
        re2c \
        repo \
        rsync \
        schedtool \
        squashfs-tools \
        sshpass \
        subversion \
        sudo \
        tar \
        texinfo \
        tmate \
        tzdata \
        unzip \
        wget \
        xsltproc \
        xxd \
        xz-utils \
        zip \
        zlib1g-dev \
        zstd && \
    if [[ "${INSTALL_EXTRA_TOOLS}" == "true" ]]; then \
        apt-get install -y --no-install-recommends \
            htop ncftp nodejs w3m; \
    fi && \
    update-alternatives \
        --set java \
        /usr/lib/jvm/java-17-openjdk-amd64/bin/java && \
    update-alternatives \
        --set javac \
        /usr/lib/jvm/java-17-openjdk-amd64/bin/javac && \
    echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen && \
    locale-gen && \
    rm -rf /var/lib/apt/lists/* && \
    create-builder-user && \
    rm -f /usr/local/bin/create-builder-user

USER ${USERNAME}
WORKDIR /workspace

RUN test "$(id -u)" = "${USER_UID}" && \
    test "$(id -g)" = "${USER_GID}" && \
    test -w "${HOME}" && \
    git config --global init.defaultBranch main && \
    git config --global core.editor nano && \
    git config --global --add safe.directory /workspace && \
    command -v repo && \
    command -v java && \
    command -v javac && \
    command -v ccache && \
    command -v adb && \
    command -v fastboot

VOLUME ["/workspace", "/home/builder/.cache/ccache"]

CMD ["/bin/bash"]
