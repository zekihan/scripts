#!/usr/bin/env bash

# -e: exit on error
# -u: exit on unset variables
set -eu

INSTALLER_OWNER="zekihan"
INSTALLER_REPO="scripts"

TARGET_OWNER="junegunn"
TARGET_REPO="fzf"

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
latest_version=${latest_version_tag}
file="fzf-${latest_version}-${os}_${arch}"

case $os in
	linux)
		file_ext="tar.gz"
		;;
	darwin)
		file_ext="zip"
		;;
	*)
		echo "Unsupported OS: ${os}"
		exit 1
		;;
esac

output_file="${tmp_dir}/fzf.${file_ext}"
url="https://github.com/${TARGET_OWNER}/${TARGET_REPO}/releases/download/${latest_version}/${file}.${file_ext}"

download_file "${url}" "${output_file}"

case $file_ext in
	zip)
		unzip "${output_file}" -d "${tmp_dir}"
		;;
	tar.gz)
		tar -xf "${output_file}" -C "${tmp_dir}"
		;;
esac

copy_and_set_permissions "${tmp_dir}/fzf"

echo "Installed fzf ${latest_version}"

fzf --version

rm -rf "${tmp_dir}"
