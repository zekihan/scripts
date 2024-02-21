#!/usr/bin/env bash

set -e

REPO="jqlang/jq"

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
check_command awk

get_os() {
	os=$(uname -s)
	case $os in
	Darwin)
		echo "macos"
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
	curl --silent "https://api.github.com/repos/$repo/releases/latest" | grep tag_name | awk -F 'tag_name' '{print $2}' | awk -F '"' '{print $3}'
}

tmp_dir=$(mktemp -d)

os=$(get_os)
arch=$(get_arch)
latest_version_tag=$(get_latest_release $REPO)
latest_version=${latest_version_tag#jq-}
file=jq-"$os"-"$arch"

curl --silent --show-error --location \
	https://github.com/"$REPO"/releases/download/jq-"$latest_version"/"$file" \
	-o "$tmp_dir"/"$file" || {
	echo "Download failed. Aborting."
	exit 1
}

mv "$tmp_dir"/"$file" "$tmp_dir"/jq

copy_and_set_permissions "$tmp_dir"/jq

echo "Installed jq $latest_version"

rm -rf "$tmp_dir"
