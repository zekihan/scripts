#!/usr/bin/env bash

# -e: exit on error
# -u: exit on unset variables
set -eu

function get_arch_type_1() {
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

function get_arch_type_2() {
	local arch
	arch=$(uname -m)
	case $arch in
		x86_64)
			echo "x86_64"
			;;
		aarch64)
			echo "aarch64"
			;;
		*)
			echo "Unsupported Arch: ${arch}"
			exit 1
			;;
	esac
}

function get_arch() {
	get_arch_type_1 "$@"
}
