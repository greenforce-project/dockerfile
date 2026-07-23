#!/usr/bin/env bash
set -Eeuo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${root}"

workflow_file=".github/workflows/build.yml"

shell_files=(
    scripts/create-builder-user.sh
    scripts/lint-repository.sh
    scripts/verify.sh
)

dockerfiles=(
    ubuntu/kernel/Dockerfile
    ubuntu/rom/Dockerfile
    ubuntu/toolchain/Dockerfile
    debian/kernel/Dockerfile
    debian/rom/Dockerfile
    debian/toolchain/Dockerfile
)

assert_first_line() {
    local file="$1"
    local expected="$2"
    local actual

    if [[ ! -f "${file}" ]]; then
        printf 'Missing required file: %s\n' "${file}" >&2
        exit 1
    fi

    IFS= read -r actual < "${file}"
    actual="${actual%$'\r'}"

    if [[ "${actual}" != "${expected}" ]]; then
        printf 'Invalid first line in %s\n' "${file}" >&2
        printf 'Expected: %s\n' "${expected}" >&2
        printf 'Actual  : %s\n' "${actual}" >&2
        exit 1
    fi
}

assert_first_line \
    "${workflow_file}" \
    "name: Build and publish images"

for file in "${shell_files[@]}"; do
    assert_first_line "${file}" "#!/usr/bin/env bash"
done

for file in "${dockerfiles[@]}"; do
    assert_first_line "${file}" "# syntax=docker/dockerfile:1"
done

bash -n "${shell_files[@]}"

workflow_markers=(
    "ubuntu/kernel/Dockerfile"
    "ubuntu/rom/Dockerfile"
    "ubuntu/toolchain/Dockerfile"
    "debian/kernel/Dockerfile"
    "debian/rom/Dockerfile"
    "debian/toolchain/Dockerfile"
    "needs: validate"
    "actions/checkout@v7"
    "docker/setup-buildx-action@v4"
    "docker/build-push-action@v7"
)

for marker in "${workflow_markers[@]}"; do
    if ! grep -Fq "${marker}" "${workflow_file}"; then
        printf 'Workflow marker not found: %s\n' "${marker}" >&2
        exit 1
    fi
done

for file in debian/*/Dockerfile; do
    if ! grep -Fq \
        "scripts/create-builder-user.sh" \
        "${file}"; then
        printf 'Builder helper is not used by %s\n' "${file}" >&2
        exit 1
    fi
done

if [[ -f .dockerignore ]] && \
   grep -Eq '^[[:space:]]*scripts/?[[:space:]]*$' .dockerignore; then
    printf 'The scripts directory must be available in Docker build context.\n' >&2
    exit 1
fi

if grep -R -nE \
    'FROM[[:space:]]+(ubuntu|debian):latest|apt-key|curl[^|]*\|[[:space:]]*(sudo[[:space:]]+)?(ba)?sh' \
    --include='Dockerfile' \
    ubuntu debian; then
    printf 'Unsafe or unpinned Dockerfile pattern found.\n' >&2
    exit 1
fi

git diff --check

if command -v ruby >/dev/null 2>&1; then
    ruby -e \
        'require "yaml"; Psych.parse_file(ARGV.fetch(0))' \
        "${workflow_file}"
fi

if command -v actionlint >/dev/null 2>&1; then
    actionlint "${workflow_file}"
fi

printf 'Repository checks passed.\n'
