#!/usr/bin/env bash

# -e: exit on error
# -u: exit on unset variables
set -eu

INSTALLER_OWNER="zekihan"
INSTALLER_REPO="scripts"

TARGET_OWNER="PixlOne"
TARGET_REPO="logiops"

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
	if command -v logid >/dev/null; then
		version=$(logid --version)
		version=${version#v}
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
		echo "Force mode is enabled. Installing logid ${latest_version} regardless of the current version."
	else
		compare_versions_and_exit "${current_version}" "${latest_version}"
		if [ "${current_version}" = "0.0.0" ]; then
			echo "Installing logid ${latest_version}."
		else
			echo "Upgrading logid ${current_version} -> ${latest_version}"
		fi
	fi

	if command -v pacman >/dev/null; then
		sudo pacman -Syu --noconfirm base-devel cmake libevdev libconfig systemd-libs glib2
	elif command -v apt >/dev/null; then
		sudo apt-get install -y build-essential cmake pkg-config libevdev-dev libudev-dev libconfig++-dev libglib2.0-dev
	elif command -v dnf >/dev/null; then
		sudo dnf -y install cmake libevdev-devel systemd-devel libconfig-devel gcc-c++ glib2-devel
	elif command -v emerge >/dev/null; then
		sudo emerge --ask n dev-libs/libconfig dev-libs/libevdev dev-libs/glib dev-util/cmake virtual/libudev
	elif command -v eopkg >/dev/null; then
		sudo eopkg install -y cmake libevdev-devel libconfig-devel libgudev-devel glib2-devel
	elif command -v zypper >/dev/null; then
		sudo zypper -n install cmake libevdev-devel systemd-devel libconfig-devel gcc-c++ libconfig++-devel libudev-devel glib2-devel
	else
		echo "Unsupported package manager. Aborting." >&2
		exit 1
	fi

	tmp_dir=$(mktemp -d)
	repo_install_path="${tmp_dir}/${TARGET_REPO}"
	mkdir -p "${repo_install_path}"

	git clone "https://github.com/${TARGET_OWNER}/${TARGET_REPO}.git" "${repo_install_path}"

	mkdir -p "${repo_install_path}/build"

	cd "${repo_install_path}/build"

	cmake -DCMAKE_BUILD_TYPE=Release ..

	make

	sed -i "/ExecStart=/ s|$| -c ${HOME}/.config/logid/config.cfg|" "logid.service"

	sudo make install

	sudo systemctl enable --now logid

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
