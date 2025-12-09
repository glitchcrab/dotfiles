#!/usr/bin/env bash

DISPLAY=:0
ENVFILE=/tmp/polybar.env

if [ `xrandr | grep -E '\sconnected' | wc -l` -gt 1 ]; then
    SIDEMARGIN=20
    TOPMARGIN=5
else
    SIDEMARGIN=0
    TOPMARGIN=0
fi

echo "SIDEMARGIN=${SIDEMARGIN}" > ${ENVFILE}
echo "TOPMARGIN=${TOPMARGIN}" >> ${ENVFILE}

for bar in $(systemctl --type=service --state=running --user | awk '/polybar/ {print $1}'); do
    systemctl --user stop ${bar}
    pkill polybar || true
done

while pgrep -u $UID -x polybar >/dev/null; do
    echo "waiting for polybar process to die"
    sleep 1
done

if type "xrandr" > /dev/null; then
    if ! systemctl --user is-active --quiet snixembed.service; then
        systemctl --user start snixembed.service
    fi
    for display in $(xrandr | awk '/ connected/ {print $1}'); do
        systemctl --user start polybar@${display}
    done
fi
