#!/usr/bin/env bash

# -e: exit on error
# -u: exit on unset variables
set -eu

url="get.chezmoi.io"
if command -v curl >/dev/null; then
	sh -c "$(curl -fsSL "${url}")" -- -b "/usr/local/bin"
elif command -v wget >/dev/null; then
	sh -c "$(wget -qO- "${url}")" -- -b "/usr/local/bin"
fi
