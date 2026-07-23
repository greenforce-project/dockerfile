# Contributing

1. Create a branch from `main`.
2. Keep each dependency addition tied to a concrete build requirement.
3. Build the affected image locally with `make build-kernel`, `make build-rom`, or `make build-toolchain`.
4. Run `make verify` after building all images.
5. Open a pull request and explain compatibility, security, and image-size implications.

Do not add credentials, personal Git configuration, unpinned remote installation scripts, or background services to an image.
