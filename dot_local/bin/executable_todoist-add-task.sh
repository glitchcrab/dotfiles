#!/usr/bin/env bash
task=$(rofi -show drun -dmenu -config /home/shw/.config/rofi/todoist-task.rasi -p "Todoist:")
#description=$(rofi -show drun -dmenu -config /home/shw/.config/rofi/todoist-description.rasi -p "Todoist:")

tod task quick-add -c "${task}"
exit 0

if [[ ! -z “${task}” ]]; then
    if [[ -z “${description}” ]]; then
        tod task quick-add -c "${task}"
    else
        tod task quick-add -c "${task}" -d "${description}"
    fi
fi
