#!/usr/bin/env bash

# -e: exit on error
# -u: exit on unset variables
set -eu

sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "/usr/local/bin"
