#!/usr/bin/env bash

# -e: exit on error
# -u: exit on unset variables
set -eu

curl -sS https://starship.rs/install.sh | sh
