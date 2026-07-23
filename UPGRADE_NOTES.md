# Upgrade Notes

## Breaking repository-layout changes

The original files have been moved to standard Dockerfile locations:

- `ubuntu/kernel` -> `ubuntu/kernel/Dockerfile`
- `ubuntu/rom` -> `ubuntu/rom/Dockerfile`
- `ubuntu/tc` -> `ubuntu/toolchain/Dockerfile`

Docker Hub tags are unchanged: `k-ubuntu`, `r-ubuntu`, and `t-ubuntu`.

## Repository settings required

Create or update these GitHub Actions secrets:

- `DOCKER_USERNAME`
- `DOCKER_PASSWORD`, containing a Docker Hub access token

Delete the unused `GH_TOKEN` secret after confirming that no other workflow needs it.

## First rollout

1. Apply the patch or replace the repository contents with this package.
2. Push the changes to a feature branch.
3. Let the pull-request workflow build all images without publishing them.
4. Merge only after all three matrix jobs succeed.
5. Run the workflow manually once and verify the three Docker Hub tags.

## Compatibility notes

- The ROM image intentionally remains on Ubuntu 22.04 LTS for broader compatibility with older Android branches.
- Java 17 is the default. Java 8 and Java 11 remain installed unless `INSTALL_LEGACY_JDKS=false` is supplied.
- Published images target `linux/amd64`, matching the previous ROM assumptions and multilib dependencies.
