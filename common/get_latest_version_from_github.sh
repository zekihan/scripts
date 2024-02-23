#!/usr/bin/env bash

# -e: exit on error
# -u: exit on unset variables
set -eu

function get_with_curl() {
	local url
	local headers
	local response
	url=$1
	headers=(-H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28")
	# Disable -u
	set +u
	if [ -n "${GITHUB_TOKEN}" ]; then
		headers+=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
	fi
	# Re-enable -u
	set -u
	if ! response=$(curl -sL --fail-with-body "${headers[@]}" "${url}"); then
		echo -e "Failed to get response from ${url}\n${response}" >&2
		exit 1
	fi
	echo "$response"
}

function get_with_wget() {
	local url
	local headers
	local response
	url=$1
	headers=(--header="Accept: application/vnd.github+json" --header="X-GitHub-Api-Version: 2022-11-28")
	# Disable -u
	set +u
	if [ -n "${GITHUB_TOKEN}" ]; then
		headers+=(--header="Authorization: Bearer ${GITHUB_TOKEN}")
	fi
	# Re-enable -u
	set -u
	if ! response=$(wget -qO- --content-on-error "${headers[@]}" "${url}" 2>/dev/null); then
		echo -e "Failed to get response from ${url}\n${response}" >&2
		exit 1
	fi
	echo "$response"
}

function parse_with_jq() {
	local response
	response=$1
	echo "$response" | jq -r .tag_name
}

function parse_with_awk() {
	local response
	response=$1
	echo "$response" | grep tag_name | awk -F 'tag_name' '{print $2}' | awk -F '"' '{print $3}'
}

function get_latest_release() {
	local owner
	local repo
	local url
	local response
	owner=$1
	repo=$2
	url="https://api.github.com/repos/${owner}/${repo}/releases/latest"

	response=""
	if command -v curl >/dev/null; then
		if ! response=$(get_with_curl "${url}"); then
			exit 1
		fi
	elif command -v wget >/dev/null; then
		if ! response=$(get_with_wget "${url}"); then
			exit 1
		fi
	else
		echo "curl or wget is required but it's not installed. Aborting." >&2
		exit 1
	fi

	if command -v jq >/dev/null; then
		parse_with_jq "${response}"
	else
		parse_with_awk "${response}"
	fi
}
