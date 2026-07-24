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
    HOME=/home/${USERNAME} \
    CCACHE_DIR=/home/${USERNAME}/.cache/ccache \
    PATH=/home/${USERNAME}/.local/bin:${PATH}

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
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    existing_group="$(getent group "${USER_GID}" | cut -d: -f1 || true)"; \
    if [[ -n "${existing_group}" ]]; then \
        if [[ "${existing_group}" != "${USERNAME}" ]]; then \
            groupmod --new-name "${USERNAME}" "${existing_group}"; \
        fi; \
    elif getent group "${USERNAME}" >/dev/null; then \
        groupmod --gid "${USER_GID}" "${USERNAME}"; \
    else \
        groupadd --gid "${USER_GID}" "${USERNAME}"; \
    fi; \
    existing_user="$(getent passwd "${USER_UID}" | cut -d: -f1 || true)"; \
    if [[ -n "${existing_user}" ]]; then \
        if [[ "${existing_user}" != "${USERNAME}" ]]; then \
            usermod --login "${USERNAME}" --home "/home/${USERNAME}" \
                --gid "${USER_GID}" --shell /bin/bash "${existing_user}"; \
        else \
            usermod --home "/home/${USERNAME}" --gid "${USER_GID}" \
                --shell /bin/bash "${USERNAME}"; \
        fi; \
    elif id -u "${USERNAME}" >/dev/null 2>&1; then \
        usermod --uid "${USER_UID}" --home "/home/${USERNAME}" \
            --gid "${USER_GID}" --shell /bin/bash "${USERNAME}"; \
    else \
        useradd --uid "${USER_UID}" --gid "${USER_GID}" \
            --create-home --shell /bin/bash "${USERNAME}"; \
    fi; \
    test "$(id -u "${USERNAME}")" = "${USER_UID}"; \
    test "$(id -g "${USERNAME}")" = "${USER_GID}"; \
    printf '%s ALL=(ALL) NOPASSWD:ALL\n' "${USERNAME}" > "/etc/sudoers.d/${USERNAME}"; \
    chmod 0440 "/etc/sudoers.d/${USERNAME}"; \
    install -d -m 0755 -o "${USER_UID}" -g "${USER_GID}" \
        "/home/${USERNAME}" /workspace; \
    install -d -m 0755 -o "${USER_UID}" -g "${USER_GID}" \
        "/home/${USERNAME}/.cache" \
        "/home/${USERNAME}/.cache/ccache"; \
    chown -R "${USER_UID}:${USER_GID}" "/home/${USERNAME}"

USER ${USERNAME}
WORKDIR /workspace

RUN test "$(id -u)" = "${USER_UID}" && \
    test "$(id -g)" = "${USER_GID}" && \
    test -d "${HOME}" && \
    test -w "${HOME}" && \
    git config --global init.defaultBranch main && \
    git config --global --add safe.directory /workspace && \
    command -v gcc && \
    command -v clang && \
    command -v aarch64-linux-gnu-gcc && \
    command -v arm-linux-gnueabi-gcc && \
    command -v make && \
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
