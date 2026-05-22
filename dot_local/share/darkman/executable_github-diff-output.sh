#!/usr/bin/env bash

set -e
set -u
set -o pipefail

mode="${1}"

if [[ "${mode}" == "light" ]]; then
    sed -i "s/syntax-theme.* # auto-switched by darkman/syntax-theme = GitHub # auto-switched by darkman/g" ~/.gitconfig
elif [[ "${mode}" == "dark" ]]; then
    sed -i "s/syntax-theme.* # auto-switched by darkman/syntax-theme = Coldark-Dark # auto-switched by darkman/g" ~/.gitconfig
fi
