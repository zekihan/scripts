#!/usr/bin/env bash

# -e: exit on error
# -u: exit on unset variables
set -eu

function get_latest_release_with_jq() {
	owner=$1
	repo=$2
	if command -v curl >/dev/null; then
		curl --silent "https://api.github.com/repos/${owner}/${repo}/releases/latest" | jq -r .tag_name
	elif command -v wget >/dev/null; then
		wget -qO- "https://api.github.com/repos/${owner}/${repo}/releases/latest" | jq -r .tag_name
	else
		echo "curl or wget is required but it's not installed. Aborting." >&2
		exit 1
	fi
}

function get_latest_release_without_jq() {
	owner=$1
	repo=$2
	if command -v curl >/dev/null; then
		curl --silent "https://api.github.com/repos/${owner}/${repo}/releases/latest" | grep tag_name | awk -F 'tag_name' '{print $2}' | awk -F '"' '{print $3}'
	elif command -v wget >/dev/null; then
		wget -qO- "https://api.github.com/repos/${owner}/${repo}/releases/latest" | grep tag_name | awk -F 'tag_name' '{print $2}' | awk -F '"' '{print $3}'
	else
		echo "curl or wget is required but it's not installed. Aborting." >&2
		exit 1
	fi
}

function get_latest_release() {
	if command -v jq >/dev/null; then
		get_latest_release_with_jq "$@"
	else
		get_latest_release_without_jq "$@"
	fi
}
