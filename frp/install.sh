#!/usr/bin/env bash

# -e: exit on error
# -u: exit on unset variables
set -eu

INSTALLER_OWNER="zekihan"
INSTALLER_REPO="scripts"

TARGET_OWNER="fatedier"
TARGET_REPO="frp"

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

is_server=1
is_client=1

# Disable -u
set +u

if [ "$1" == "server" ]; then
	is_client=0
elif [ "$1" == "client" ]; then
	is_server=0
fi

# Re-enable -u
set -u

tmp_dir=$(mktemp -d)

os=$(get_os)
arch=$(get_arch)
latest_version_tag=$(get_latest_release $TARGET_OWNER $TARGET_REPO)
latest_version=${latest_version_tag#v}
file="frp_${latest_version}_${os}_${arch}"

output_file="${tmp_dir}/frp.tar.gz"
url="https://github.com/${TARGET_OWNER}/${TARGET_REPO}/releases/download/v${latest_version}/${file}.tar.gz"

download_file "${url}" "${output_file}"

tar -xf "${output_file}" -C "${tmp_dir}"

if [ "${is_server}" -eq 1 ]; then
	copy_and_set_permissions "${tmp_dir}/${file}/frps"
fi
if [ "${is_client}" -eq 1 ]; then
	copy_and_set_permissions "${tmp_dir}/${file}/frpc"
fi

if [ "${os}" == "linux" ] && [ -d /etc/systemd/system ] && command -v systemctl &>/dev/null; then
	if [ "${is_server}" -eq 1 ]; then
		source_file "frp/systemd/frps@.service" >/etc/systemd/system/frps@.service
		sudo mkdir -p /etc/frps
	fi
	if [ "${is_client}" -eq 1 ]; then
		source_file "frp/systemd/frpc@.service" >/etc/systemd/system/frpc@.service
		sudo mkdir -p /etc/frpc
	fi
	sudo systemctl daemon-reload
fi

if [ "${is_server}" -eq 1 ]; then
	echo "Installed frp server ${latest_version}"
	frps --version
fi
if [ "${is_client}" -eq 1 ]; then
	echo "Installed frp client ${latest_version}"
	frpc --version
fi

rm -rf "${tmp_dir}"
