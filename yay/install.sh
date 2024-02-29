#!/usr/bin/env bash

# -e: exit on error
# -u: exit on unset variables
set -eu

INSTALLER_OWNER="zekihan"
INSTALLER_REPO="scripts"

TARGET_OWNER="Jguer"
TARGET_REPO="yay"

function source_from_local() {
	local file_path
	file_path=$1
	cat "../${file_path}"
}

function source_from_remote() {
	local file_path
	local url
	file_path=$1
	url="https://raw.githubusercontent.com/${INSTALLER_OWNER}/${INSTALLER_REPO}/main/${file_path}"
	if command -v curl >/dev/null; then
		curl -fsSL "${url}"
	elif command -v wget >/dev/null; then
		wget -qO- "${url}"
	fi
}

function source_file() {
	local file_path
	file_path=$1
	if [ -f "../${file_path}" ]; then
		source_from_local "${file_path}"
	elif command -v curl >/dev/null || command -v wget >/dev/null; then
		source_from_remote "${file_path}"
	else
		echo "curl or wget is required but it's not installed. Aborting." >&2
		exit 1
	fi
}

# shellcheck source=common/source_commons.sh
eval "$(source_file common/source_commons.sh)"

function get_current_version() {
	local version
	version="0.0.0"
	if command -v yay >/dev/null; then
		version=$(yay --version)
		version=${version#yay v}
		version=${version%% *}
	fi
	echo "${version}"
}

function main() {
	if ! latest_version_tag=$(get_latest_release "${TARGET_OWNER}" "${TARGET_REPO}"); then
		exit 1
	fi
	latest_version=${latest_version_tag#v}
	current_version=$(get_current_version)

	if ${FORCE}; then
		echo "Force mode is enabled. Installing yay ${latest_version} regardless of the current version."
	else
		compare_versions_and_exit "${current_version}" "${latest_version}"
		if [ "${current_version}" = "0.0.0" ]; then
			echo "Installing yay ${latest_version}."
		else
			echo "Upgrading yay ${current_version} -> ${latest_version}"
		fi
	fi

	tmp_dir=$(mktemp -d)
	repo_install_path="${tmp_dir}/${TARGET_REPO}"
	mkdir -p "${repo_install_path}"

	sudo pacman -Syu --noconfirm --needed git base-devel

	git clone "https://aur.archlinux.org/${TARGET_REPO}.git" "${repo_install_path}"

	cd "${repo_install_path}"

	makepkg -si --noconfirm

	cd -

	rm -rf "${tmp_dir}"
}

FORCE=false

while getopts ":f" opt; do
	case ${opt} in
		f)
			FORCE=true
			;;
		\?)
			echo "Invalid option: $OPTARG" 1>&2
			exit 1
			;;
	esac
done
shift $((OPTIND - 1))

main
