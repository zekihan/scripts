#!/usr/bin/env bash

# -e: exit on error
# -u: exit on unset variables
set -eu

function get_os_type_1() {
	local os
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

function get_os_type_2() {
	local os
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

function get_os() {
	get_os_type_1 "$@"
}
