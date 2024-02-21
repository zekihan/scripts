#!/usr/bin/env bash

# -e: exit on error
# -u: exit on unset variables
set -eu

INSTALLER_OWNER="zekihan"
INSTALLER_REPO="scripts"

TARGET_OWNER="mikefarah"
TARGET_REPO="yq"

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

tmp_dir=$(mktemp -d)

os=$(get_os)
arch=$(get_arch)
latest_version_tag=$(get_latest_release $TARGET_OWNER $TARGET_REPO)
latest_version=${latest_version_tag#v}
file="yq_${os}_${arch}"

output_file="${tmp_dir}/yq"
url="https://github.com/${TARGET_OWNER}/${TARGET_REPO}/releases/download/v${latest_version}/${file}"

download_file "${url}" "${output_file}"

copy_and_set_permissions "${output_file}"

echo "Installed yq ${latest_version}"

yq --version

rm -rf "${tmp_dir}"
