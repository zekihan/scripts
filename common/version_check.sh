#!/usr/bin/env bash

# -e: exit on error
# -u: exit on unset variables
set -eu

function compare_versions() {
	IFS='.' read -ra VERSION1 <<<"$1"
	IFS='.' read -ra VERSION2 <<<"$2"

	for i in "${!VERSION1[@]}"; do
		if ((VERSION1[i] > VERSION2[i])); then
			echo "-1"
			return
		elif ((VERSION1[i] < VERSION2[i])); then
			echo "1"
			return
		fi
	done

	echo "0"
}

function compare_versions_and_exit() {
	need_to_install=$(compare_versions "${1}" "${2}")
	if [ "${need_to_install}" -ne 1 ]; then
		echo "Current version is up to date"
		exit 0
	fi
}
