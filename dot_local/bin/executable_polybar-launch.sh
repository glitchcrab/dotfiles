#!/usr/bin/env bash
DISPLAY=:0

if [ `xrandr | grep -E '\sconnected' | wc -l` -gt 1 ]; then
  export SIDEMARGIN=20
  export TOPMARGIN=5
else
  export SIDEMARGIN=0
  export TOPMARGIN=0
fi

pkill -x polybar

while pgrep -u $UID -x polybar >/dev/null; do
    echo "waiting for polybar process to die"
    sleep 1
done

if type "xrandr" > /dev/null; then
    for display in $(xrandr | awk '/ connected/ {print $1}'); do
        /usr/bin/polybar -c ~/.config/polybar/config.ini --reload ${display} & disown
    done
fi
