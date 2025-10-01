#!/usr/bin/env bash

updates_arch="0"
updates_aur="0"

if updates_arch=$(checkupdates 2>/dev/null | wc -l); then
    :
else
    updates_arch="!"
fi

if updates_aur=$(paru -Qau 2>/dev/null | wc -l); then
    :
else
    updates_aur="!"
fi

if [[ "$updates_arch" == "!" || "$updates_aur" == "!" ]]; then
    echo "${updates_arch}/${updates_aur}"
else
    total=$((updates_arch + updates_aur))
    if (( total > 0 )); then
        echo "${updates_arch}/${updates_aur}"
    else
        echo ""
    fi
fi
