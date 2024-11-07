#!/bin/bash

set -e

BASE_DIR="/home/git"

if [ -z "${1}" ] || [ -z "${2}" ]; then
    echo "Usage: $0 <user> <repo>"
    exit 1
fi

cd "${BASE_DIR}"

user="${1}"
repo="${2}"

repo_path="${BASE_DIR}/${user}/${repo}.git"
repo_path_2="${BASE_DIR}/${user}/${repo}"

if [ -d "${repo_path}" ]; then
    echo "Repo already exists"
    exit 1
fi

mkdir -p "${repo_path}"

rm -rf "${repo_path_2}"

ln -s "${repo_path}" "${repo_path_2}"

cd "${repo_path}"

git init --bare
