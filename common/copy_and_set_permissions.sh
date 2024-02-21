#!/usr/bin/env bash

# -e: exit on error
# -u: exit on unset variables
set -eu

function copy_and_set_permissions() {
	local file
	local file_name
	file=$1
	file_name=$(basename "${file}")
	sudo cp "${file}" /usr/local/bin/
	if [ -f "/usr/local/bin/${file_name}" ]; then
		sudo chmod +x "/usr/local/bin/${file_name}"
	else
		echo "Failed to copy '${file}' to /usr/local/bin/${file_name}" >&2
		exit 1
	fi
}
