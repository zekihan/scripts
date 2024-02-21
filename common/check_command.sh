#!/usr/bin/env bash

# -e: exit on error
# -u: exit on unset variables
set -eu

function check_command() {
	local command_name
	command_name=$1
	command -v "${command_name}" >/dev/null 2>&1 || {
		echo >&2 "${command_name} is required but it's not installed. Aborting."
		exit 1
	}
}
