#!/usr/bin/env bash
task=$(rofi -show drun -dmenu -config /home/shw/.config/rofi/todoist-task.rasi -p "Todoist:")
description=$(rofi -show drun -dmenu -config /home/shw/.config/rofi/todoist-description.rasi -p "Todoist:")

if [[ ! -z “${task}” ]]; then
    if [[ -z “${description}” ]]; then
        tod task create -c "${task}" --priority 4 -l sorting
    else
        tod task create -c "${task}" -d "${description}" --priority 4 -l sorting
    fi
fi
