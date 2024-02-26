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
