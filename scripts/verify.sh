#!/usr/bin/env bash

set -Eeuo pipefail

image="${1:-mhmmdfdlyas/dockerfile}"

check_image() {
    local tag="$1"
    shift

    printf 'Checking default root runtime: %s:%s\n' \
        "${image}" \
        "${tag}"

    docker run \
        --rm \
        --entrypoint /bin/bash \
        "${image}:${tag}" \
        -lc "
            set -Eeuo pipefail

            test \"\$(id -u)\" = 0
            test \"\$(id -g)\" = 0
            test \"\${HOME}\" = /root

            for command_name in $*; do
                command -v \"\${command_name}\" >/dev/null
            done
        "

    printf 'Checking optional builder runtime: %s:%s\n' \
        "${image}" \
        "${tag}"

    docker run \
        --rm \
        --user builder \
        --env HOME=/home/builder \
        --env CCACHE_DIR=/home/builder/.cache/ccache \
        --entrypoint /bin/bash \
        "${image}:${tag}" \
        -lc "
            set -Eeuo pipefail

            test \"\$(id -u)\" = 1000
            test \"\$(id -g)\" = 1000
            test -d \"\${HOME}\"
            test -w \"\${HOME}\"

            for command_name in $*; do
                command -v \"\${command_name}\" >/dev/null
            done
        "

    local temp_directory
    temp_directory="$(mktemp -d)"

    mkdir -p \
        "${temp_directory}/_runner_file_commands"

    chmod 0755 \
        "${temp_directory}" \
        "${temp_directory}/_runner_file_commands"

    printf 'Checking GitHub runner write access: %s:%s\n' \
        "${image}" \
        "${tag}"

    if ! docker run \
        --rm \
        --volume "${temp_directory}:/__w/_temp" \
        --entrypoint /bin/bash \
        "${image}:${tag}" \
        -lc '
            set -Eeuo pipefail

            test "$(id -u)" = 0

            test_file="$(
                printf "%s" \
                    "/__w/_temp/_runner_file_commands/save_state_test"
            )"

            touch "${test_file}"
            printf "%s\n" "test" >> "${test_file}"
            test -s "${test_file}"
        '
    then
        rm -rf "${temp_directory}"
        return 1
    fi

    rm -rf "${temp_directory}"
}

check_image \
    k-ubuntu \
    gcc \
    clang \
    make \
    ccache \
    aarch64-linux-gnu-gcc

check_image \
    r-ubuntu \
    repo \
    java \
    javac \
    ccache \
    adb \
    fastboot

check_image \
    t-ubuntu \
    gcc \
    g++ \
    clang \
    cmake \
    meson \
    ninja \
    ccache

check_image \
    k-debian \
    gcc \
    clang \
    make \
    ccache \
    aarch64-linux-gnu-gcc

check_image \
    r-debian \
    repo \
    java \
    javac \
    ccache \
    adb \
    fastboot

check_image \
    t-debian \
    gcc \
    g++ \
    clang \
    cmake \
    meson \
    ninja \
    ccache

printf 'All image checks passed.\n'
