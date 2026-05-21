#!/usr/bin/env bash

set -e
set -u
set -o pipefail

mode="${1}"

# Check if the theme directory exists, if not create it
if [[ ! -d ~/.config/theme ]]; then
    mkdir -p ~/.config/theme
fi

echo "${mode}" > ~/.config/theme/current

if [[ "${mode}" == "light" ]]; then
    sed -i "s/dark.toml/light.toml/g" ~/.config/alacritty/alacritty.toml
elif [[ "${mode}" == "dark" ]]; then
    sed -i "s/light.toml/dark.toml/g" ~/.config/alacritty/alacritty.toml
fi
