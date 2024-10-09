#!/usr/bin/env bash
set -x
DISPLAY=:0

if [ `xrandr | grep -E '\sconnected' | wc -l` -gt 1 ]; then
  export SIDEMARGIN=20
  export TOPMARGIN=5
else
  export SIDEMARGIN=0
  export TOPMARGIN=0
fi

killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 0.1; done

if type "xrandr" > /dev/null; then
  for mon in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    /usr/bin/polybar -c ~/.config/polybar/config.ini --reload $mon & disown
  done
fi
