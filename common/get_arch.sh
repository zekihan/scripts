#!/usr/bin/env bash

# -e: exit on error
# -u: exit on unset variables
set -eu

function get_arch() {
	local arch
	arch=$(uname -m)
	case $arch in
	x86_64)
		echo "amd64"
		;;
	aarch64)
		echo "arm64"
		;;
	*)
		echo "Unsupported Arch: ${arch}"
		exit 1
		;;
	esac
}
