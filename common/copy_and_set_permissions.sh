#!/usr/bin/env bash

# -e: exit on error
# -u: exit on unset variables
set -eu

function run_elevated() {
	if [ "$(id -u)" -ne 0 ]; then
		if command -v sudo >/dev/null; then
			sudo "$@"
		else
			su -c "$*"
		fi
	else
		"$@"
	fi
}

function copy_and_set_permissions() {
	local file
	local file_name
	file=$1
	file_name=$(basename "${file}")
	run_elevated cp "${file}" /usr/local/bin/
	if [ -f "/usr/local/bin/${file_name}" ]; then
		run_elevated chmod +x "/usr/local/bin/${file_name}"
	else
		echo "Failed to copy '${file}' to /usr/local/bin/${file_name}" >&2
		exit 1
	fi
}
