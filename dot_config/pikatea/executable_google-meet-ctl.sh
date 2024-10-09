#!/bin/bash
export DISPLAY=:0

if [[ $1 == "mute" ]]; then
  command="Control_L+d"
  message="Mute toggled"
elif [[ $1 == "hand" ]]; then
  command="Control_L+Alt+h"
  message="Hand toggled"
elif [[ -z $1 ]]; then
  exit 0
fi

current_window=$(DISPLAY=:0 xdotool getactivewindow)
chrome_window=$(DISPLAY=:0 xdotool search --onlyvisible Chromium)
chrome_tab=$(DISPLAY=:0 xdotool search --name ^Meet)

xdotool windowactivate ${chrome_tab} && \
  sleep 0.5 && \
  xdotool key ${command} && \
  notify-send "${message} in Google Meet"

xdotool windowactivate ${current_window}
