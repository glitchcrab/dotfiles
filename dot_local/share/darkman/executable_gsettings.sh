#!/usr/bin/env bash

set -e
set -u
set -o pipefail

mode="${1}"

if [[ "${mode}" == "light" ]]; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
elif [[ "${mode}" == "dark" ]]; then
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
fi
