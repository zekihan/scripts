#!/usr/bin/env bash

# -e: exit on error
# -u: exit on unset variables
set -eu

INSTALLER_OWNER="zekihan"
INSTALLER_REPO="scripts"

function source_from_local() {
	local file_path
	file_path=$1
	cat "../${file_path}"
}

function source_from_remote() {
	local file_path
	local url
	file_path=$1
	url="https://raw.githubusercontent.com/${INSTALLER_OWNER}/${INSTALLER_REPO}/main/${file_path}"
	if command -v curl >/dev/null; then
		curl -fsSL "${url}"
	elif command -v wget >/dev/null; then
		wget -qO- "${url}"
	fi
}

function source_file() {
	local file_path
	file_path=$1
	if [ -f "../${file_path}" ]; then
		source_from_local "${file_path}"
	elif command -v curl >/dev/null || command -v wget >/dev/null; then
		source_from_remote "${file_path}"
	else
		echo "curl or wget is required but it's not installed. Aborting." >&2
		exit 1
	fi
}

# shellcheck source=common/source_commons.sh
eval "$(source_file common/source_commons.sh)"

check_command zoxide
check_command atuin

hist=$(atuin history list --cmd-only)

cd_commands=$(echo "${hist}" |
	grep "^cd " |
	sed 's|^cd ||' |
  sed 's|~|/home/root|' |
  sed 's|/Users/|/home/|' |
  sed 's|/root/|/home/root/|'
	)


home_dir="${HOME}"

# shellcheck disable=SC2001
cd_commands=$(echo "${cd_commands}" | sed "s|/home/[^/]*/|${home_dir}/|g")

# Unset the -e flag to continue even if the command fails
set +e

echo "${cd_commands}" | while read -r cd_command; do
	zoxide add "${cd_command}" >/dev/null 2>&1
done

# Re-enable the -e flag
set -e
