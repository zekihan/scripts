#!/usr/bin/env bash

# -e: exit on error
# -u: exit on unset variables
set -eu

url="https://starship.rs/install.sh"
if command -v curl >/dev/null; then
	curl -fsSL "${url}" | sh
elif command -v wget >/dev/null; then
	wget -qO- "${url}" | sh
fi
