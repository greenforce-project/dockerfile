# Android Build Docker Images

Reproducible Ubuntu and Debian Docker images for Android kernel,
AOSP/custom ROM, and compiler toolchain development.

## Supported images

The Docker Hub repository is:

```text
mhmmdfdlyas/dockerfile
```

| Distribution | Purpose | Stable tag | Versioned tag | Base |
|---|---|---|---|---|
| Ubuntu | Android/Linux kernel | `k-ubuntu` | `k-ubuntu24.04` | Ubuntu 24.04 |
| Ubuntu | AOSP/custom ROM | `r-ubuntu` | `r-ubuntu22.04` | Ubuntu 22.04 |
| Ubuntu | GCC/LLVM toolchain | `t-ubuntu` | `t-ubuntu24.04` | Ubuntu 24.04 |
| Debian | Android/Linux kernel | `k-debian` | `k-debian12` | Debian 12 |
| Debian | AOSP/custom ROM | `r-debian` | `r-debian12` | Debian 12 |
| Debian | GCC/LLVM toolchain | `t-debian` | `t-debian12` | Debian 12 |

Existing Ubuntu tags remain supported.

## Pull images

### Ubuntu

```bash
docker pull mhmmdfdlyas/dockerfile:k-ubuntu
docker pull mhmmdfdlyas/dockerfile:r-ubuntu
docker pull mhmmdfdlyas/dockerfile:t-ubuntu
```

### Debian

```bash
docker pull mhmmdfdlyas/dockerfile:k-debian
docker pull mhmmdfdlyas/dockerfile:r-debian
docker pull mhmmdfdlyas/dockerfile:t-debian
```

## Run an image

Mount the source tree into `/workspace`:

```bash
docker run --rm -it \
  -v "$PWD:/workspace" \
  -v android-ccache:/home/builder/.cache/ccache \
  mhmmdfdlyas/dockerfile:r-debian
```

Containers run as `root` by default for GitHub Actions job-container compatibility. The unprivileged `builder` account remains available for explicit local use:

```bash
docker run --rm -it \
  --user builder \
  --env HOME=/home/builder \
  --env CCACHE_DIR=/home/builder/.cache/ccache \
  -v "$PWD:/workspace" \
  -v android-ccache:/home/builder/.cache/ccache \
  mhmmdfdlyas/dockerfile:k-ubuntu
```

## Build locally

Build every image:

```bash
make build
```

Build only Ubuntu:

```bash
make build-ubuntu
```

Build only Debian:

```bash
make build-debian
```

Build individual Debian images:

```bash
make build-debian-kernel
make build-debian-rom
make build-debian-toolchain
```

## Build arguments

All images support:

- `USER_UID`
- `USER_GID`
- `USERNAME`

Kernel and toolchain images support:

- `INSTALL_EXTRA_TOOLS=true`

ROM images support:

- `INSTALL_EXTRA_TOOLS=true`

The Ubuntu ROM image supports:

- `INSTALL_LEGACY_JDKS=true`

The Debian 12 ROM image uses OpenJDK 17. Use the Ubuntu ROM image
when an older Android branch requires bundled Java 8 or Java 11.

## Validation

Run repository checks:

```bash
make lint
```

After building all images, run smoke tests:

```bash
make verify
```

## Continuous integration

GitHub Actions builds six images:

1. Ubuntu Android kernel
2. Ubuntu Android ROM
3. Ubuntu toolchain
4. Debian Android kernel
5. Debian Android ROM
6. Debian toolchain

The workflow publishes stable and versioned tags. It also uses:

- Docker Buildx
- GitHub Actions build cache
- SBOM generation
- Build provenance

Required GitHub Actions secrets:

- `DOCKER_USERNAME`
- `DOCKER_PASSWORD`

Use a Docker Hub access token for `DOCKER_PASSWORD`.

## Security principles

- Base distribution versions are explicit.
- Images run as root by default for GitHub Actions job-container compatibility.
- The unprivileged `builder` account remains available through `docker run --user builder`.
- Personal Git identity is not embedded in images.
- Remote shell installers are not used.
- Package lists are removed after installation.
- UID and GID conflicts are handled during image creation.

## Repository structure

```text
.
├── ubuntu/
│   ├── kernel/Dockerfile
│   ├── rom/Dockerfile
│   └── toolchain/Dockerfile
├── debian/
│   ├── kernel/Dockerfile
│   ├── rom/Dockerfile
│   └── toolchain/Dockerfile
├── scripts/
│   ├── create-builder-user.sh
│   ├── lint-repository.sh
│   └── verify.sh
├── .github/workflows/build.yml
└── Makefile
```

## License

No explicit license has been declared. Add a license before accepting
external redistribution or contributions.
