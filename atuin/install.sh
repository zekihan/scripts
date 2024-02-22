#!/usr/bin/env bash

# -e: exit on error
# -u: exit on unset variables
set -eu

url="https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh"
bash <(curl -fsSL "${url}")
