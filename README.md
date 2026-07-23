# Android Build Docker Images

Reproducible Ubuntu-based Docker images for Android kernel, custom ROM, and compiler toolchain development.

## Available images

| Purpose | Docker Hub tag | Base image | Dockerfile |
|---|---|---|---|
| Android/Linux kernel builds | `k-ubuntu` | Ubuntu 24.04 LTS | `ubuntu/kernel/Dockerfile` |
| AOSP and custom ROM builds | `r-ubuntu` | Ubuntu 22.04 LTS | `ubuntu/rom/Dockerfile` |
| GCC, LLVM, and custom toolchains | `t-ubuntu` | Ubuntu 24.04 LTS | `ubuntu/toolchain/Dockerfile` |

The public image name remains `mhmmdfdlyas/dockerfile`, so existing pull commands remain compatible.

## Pull an image

```bash
docker pull mhmmdfdlyas/dockerfile:k-ubuntu
docker pull mhmmdfdlyas/dockerfile:r-ubuntu
docker pull mhmmdfdlyas/dockerfile:t-ubuntu
```

## Run an image

Mount the source tree into `/workspace`. The container runs as the unprivileged `builder` user by default.

```bash
docker run --rm -it \
  -v "$PWD:/workspace" \
  -v android-ccache:/home/builder/.cache/ccache \
  mhmmdfdlyas/dockerfile:r-ubuntu
```

To preserve host file ownership, build locally with matching UID and GID values:

```bash
docker build \
  -f ubuntu/rom/Dockerfile \
  --build-arg USER_UID="$(id -u)" \
  --build-arg USER_GID="$(id -g)" \
  -t android-rom-env .
```

## Build locally

```bash
make build-kernel
make build-rom
make build-toolchain
```

Build all images and run smoke checks:

```bash
make build
make verify
```

## Build options

All images support `USER_UID` and `USER_GID`. Kernel and toolchain images support `INSTALL_EXTRA_TOOLS=true`. The ROM image also supports:

- `INSTALL_LEGACY_JDKS=false` to omit Java 8 and Java 11.
- `INSTALL_EXTRA_TOOLS=true` to add optional interactive utilities.
- `UBUNTU_VERSION=<version>` to override the tested base version for local experiments.

Example:

```bash
docker build \
  -f ubuntu/rom/Dockerfile \
  --build-arg INSTALL_LEGACY_JDKS=false \
  --build-arg INSTALL_EXTRA_TOOLS=true \
  -t android-rom-env:modern .
```

## Java versions in the ROM image

Java 17 is the default. Java 8 and Java 11 are installed by default for compatibility with older Android branches. Select another version interactively when required:

```bash
sudo update-alternatives --config java
sudo update-alternatives --config javac
```

## Continuous integration

GitHub Actions validates pull requests and publishes all three tags on changes to `main`, manual runs, and the weekly schedule. The workflow uses Buildx caching, SBOM generation, and build provenance.

Configure these repository secrets before publishing:

- `DOCKER_USERNAME`: Docker Hub username.
- `DOCKER_PASSWORD`: Docker Hub access token. Do not use the account password.

The scheduled build runs every Saturday at 00:00 Asia/Jakarta.

## Design decisions

- Versioned Ubuntu LTS bases replace `ubuntu:latest`.
- Builds run as a non-root user.
- Package installation and APT cleanup occur in the same layer.
- Personal Git identity is not embedded in the images.
- The ROM image no longer clones and executes an unpinned third-party setup script.
- The deprecated `apt-key` workflow and unused external LLVM repository are removed.
- Legacy Docker GitHub Action v1 inputs are replaced by current Buildx, login, and build-push actions.

## License

No license has been declared for this repository. Add an explicit license before accepting external redistribution or contributions.
