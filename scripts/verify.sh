#!/usr/bin/env bash
set -Eeuo pipefail

image="${1:-mhmmdfdlyas/dockerfile}"

check_image() {
    local tag="$1"
    shift

    printf 'Checking %s:%s\n' "${image}" "${tag}"

    docker run --rm \
        --entrypoint /bin/bash \
        "${image}:${tag}" \
        -lc \
        "set -e
        test \"\$(id -u)\" = 1000
        test -w \"\${HOME}\"
        for command_name in $*; do
            command -v \"\${command_name}\" >/dev/null
        done"
}

check_image k-ubuntu gcc clang make ccache aarch64-linux-gnu-gcc
check_image r-ubuntu repo java javac ccache adb fastboot
check_image t-ubuntu gcc g++ clang cmake meson ninja ccache

check_image k-debian gcc clang make ccache aarch64-linux-gnu-gcc
check_image r-debian repo java javac ccache adb fastboot
check_image t-debian gcc g++ clang cmake meson ninja ccache

printf 'All image checks passed.\n'
