#!/usr/bin/env bash

# -e: exit on error
# -u: exit on unset variables
set -eu

function download_file() {
	local url
	local output_file
	url=$1
	output_file=$2
	if command -v curl >/dev/null; then
		curl --silent --show-error --location \
			"$url" \
			-o "$output_file" || {
			echo "Download failed. Aborting."
			exit 1
		}
	elif command -v wget >/dev/null; then
		wget -qO "$output_file" \
			"$url" || {
			echo "Download failed. Aborting."
			exit 1
		}
	else
		echo "curl or wget is required but it's not installed. Aborting." >&2
		exit 1
	fi
}
