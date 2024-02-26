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

# shellcheck source=common/check_command.sh
eval "$(source_file common/check_command.sh)"

# shellcheck source=common/copy_and_set_permissions.sh
eval "$(source_file common/copy_and_set_permissions.sh)"

# shellcheck source=common/download_file.sh
eval "$(source_file common/download_file.sh)"

# shellcheck source=common/get_arch.sh
eval "$(source_file common/get_arch.sh)"

# shellcheck source=common/get_latest_version_from_github.sh
eval "$(source_file common/get_latest_version_from_github.sh)"

# shellcheck source=common/get_os.sh
eval "$(source_file common/get_os.sh)"

# shellcheck source=common/run_elevated.sh
eval "$(source_file common/run_elevated.sh)"

# shellcheck source=common/version_check.sh
eval "$(source_file common/version_check.sh)"
