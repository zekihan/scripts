#!/usr/bin/env bash

set -e

INSTALLER_REPO="zekihan/scripts"
REPO="fatedier/frp"

is_server=1
is_client=1

if [ "$1" == "server" ]; then
	is_client=0
elif [ "$1" == "client" ]; then
	is_server=0
fi

check_command() {
	command -v "$1" >/dev/null 2>&1 || {
		echo >&2 "$1 is required but it's not installed. Aborting."
		exit 1
	}
}

copy_and_set_permissions() {
	sudo cp "$1" /usr/local/bin/
	sudo chmod +x /usr/local/bin/"$(basename "$1")"
}

check_command curl
check_command jq

get_os() {
	os=$(uname -s)
	case $os in
	Darwin)
		echo "darwin"
		;;
	Linux)
		echo "linux"
		;;
	*)
		echo "Unsupported OS: ${os}"
		exit 1
		;;
	esac
}

get_arch() {
	arch=$(uname -m)
	case $arch in
	x86_64)
		echo "amd64"
		;;
	aarch64)
		echo "arm64"
		;;
	*)
		echo "Unsupported Arch: ${os}"
		exit 1
		;;
	esac
}

get_latest_release() {
	repo=$1
	curl --silent "https://api.github.com/repos/$repo/releases/latest" | jq -r .tag_name
}

tmp_dir=$(mktemp -d)

os=$(get_os)
arch=$(get_arch)
latest_version_tag=$(get_latest_release $REPO)
latest_version=${latest_version_tag#v}
file=frp_"$latest_version"_"$os"_"$arch"

curl --silent --show-error --location \
	https://github.com/"$REPO"/releases/download/v"$latest_version"/"$file".tar.gz \
	-o "$tmp_dir"/"$file".tar.gz || {
	echo "Download failed. Aborting."
	exit 1
}

tar -xf "$tmp_dir"/"$file".tar.gz -C "$tmp_dir"

if [ "$is_server" -eq 1 ]; then
	copy_and_set_permissions "$tmp_dir"/"$file"/frpc
fi
if [ "$is_client" -eq 1 ]; then
	copy_and_set_permissions "$tmp_dir"/"$file"/frps
fi

if [ "$os" == "linux" ] && [ -d /etc/systemd/system ] && command -v systemctl &>/dev/null; then
	systemd_url=https://raw.githubusercontent.com/"$INSTALLER_REPO"/main/frp/systemd/
	if [ "$is_server" -eq 1 ]; then
		sudo curl -sSL -o /etc/systemd/system/frps@.service "$systemd_url"/frps%40.service
		sudo mkdir -p /etc/frps
	fi
	if [ "$is_client" -eq 1 ]; then
		sudo curl -sSL -o /etc/systemd/system/frpc@.service "$systemd_url"/frpc%40.service
		sudo mkdir -p /etc/frpc
	fi
	sudo systemctl daemon-reload
fi

if [ "$is_server" -eq 1 ]; then
	echo "Installed frp server $latest_version"
fi
if [ "$is_client" -eq 1 ]; then
	echo "Installed frp client $latest_version"
fi

rm -rf "$tmp_dir"
