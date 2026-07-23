#!/usr/bin/env bash
set -Eeuo pipefail

username="${USERNAME:-builder}"
user_uid="${USER_UID:-1000}"
user_gid="${USER_GID:-1000}"
home_dir="/home/${username}"

if [[ ! "${user_uid}" =~ ^[0-9]+$ ]] || [[ ! "${user_gid}" =~ ^[0-9]+$ ]]; then
    printf 'USER_UID and USER_GID must be numeric.\n' >&2
    exit 2
fi

existing_group="$(getent group "${user_gid}" | cut -d: -f1 || true)"

if [[ -n "${existing_group}" ]]; then
    if [[ "${existing_group}" != "${username}" ]]; then
        if getent group "${username}" >/dev/null; then
            printf 'Group %s already exists with another GID.\n' "${username}" >&2
            exit 3
        fi

        groupmod --new-name "${username}" "${existing_group}"
    fi
elif getent group "${username}" >/dev/null; then
    groupmod --gid "${user_gid}" "${username}"
else
    groupadd --gid "${user_gid}" "${username}"
fi

existing_user="$(getent passwd "${user_uid}" | cut -d: -f1 || true)"

if [[ -n "${existing_user}" ]]; then
    if [[ "${existing_user}" != "${username}" ]]; then
        if id -u "${username}" >/dev/null 2>&1; then
            printf 'User %s already exists with another UID.\n' "${username}" >&2
            exit 4
        fi

        usermod \
            --login "${username}" \
            --home "${home_dir}" \
            --gid "${user_gid}" \
            --shell /bin/bash \
            "${existing_user}"
    else
        usermod \
            --home "${home_dir}" \
            --gid "${user_gid}" \
            --shell /bin/bash \
            "${username}"
    fi
elif id -u "${username}" >/dev/null 2>&1; then
    usermod \
        --uid "${user_uid}" \
        --home "${home_dir}" \
        --gid "${user_gid}" \
        --shell /bin/bash \
        "${username}"
else
    useradd \
        --uid "${user_uid}" \
        --gid "${user_gid}" \
        --home-dir "${home_dir}" \
        --create-home \
        --shell /bin/bash \
        "${username}"
fi

install -d -m 0755 -o "${user_uid}" -g "${user_gid}" \
    "${home_dir}" \
    "${home_dir}/.cache" \
    "${home_dir}/.cache/ccache" \
    /workspace

chown -R "${user_uid}:${user_gid}" "${home_dir}"

printf '%s ALL=(ALL) NOPASSWD:ALL\n' "${username}" \
    > "/etc/sudoers.d/${username}"

chmod 0440 "/etc/sudoers.d/${username}"

test "$(id -u "${username}")" = "${user_uid}"
test "$(id -g "${username}")" = "${user_gid}"
test -w "${home_dir}"
