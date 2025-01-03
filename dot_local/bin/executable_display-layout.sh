#!/usr/bin/env bash

_STATUSFILE="/tmp/display_status.json"

if test -e $_STATUSFILE; then
    _status=`jq -r .running $_STATUSFILE`
    if [ $_status == 'true' ]; then
        exit 0
    else
        jq -n '{ "running": "true" }' | tee $_STATUSFILE > /dev/null
    fi
else
    touch $_STATUSFILE
    jq -n '{ "running": "true" }' | tee $_STATUSFILE > /dev/null
fi

_user="$(id -u -n)"
_uid="$(id -u)"

export XAUTHORITY=/home/$_user/.Xauthority
export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$_uid/bus"
export LANG=en_GB.UTF-8

MONCOUNT="$(xrandr | grep -E '\sconnected' | wc -l)"

case "$MONCOUNT" in
    3)
        LAYOUT="two_mon"
        ;;
    2)
        LAYOUT="one_mon"
        ;;
    1)
        LAYOUT="no_mon"
        ;;
    *)
        echo "cannot calculate display count"
        exit 1
esac

manage_picom() {
    if [ $1 == "start" ] && [ -z `pgrep picom` ]; then
        echo "starting picom"
        systemctl start picom --user
    elif [ $1 == "stop" ] && [ ! -z `pgrep picom` ]; then
        systemctl stop picom --user
    fi
}

set_layout() {
    if [ $LAYOUT == "two_mon" ]; then
        xrandr --output eDP-1 --primary --mode 1920x1200 --pos 3840x0 --rotate normal --output DP-1 --off --output HDMI-1 --off --output DP-2 --off --output DP-3 --off --output DP-4 --off --output DP-2-5 --off --output DP-2-5-5 --mode 1920x1200 --pos 0x0 --rotate normal --output DP-2-6 --off --output DP-2-6-6 --mode 1920x1200 --pos 1920x0 --rotate normal
        #xrandr --output eDP1 --primary --mode 1920x1080 --pos 0x1200 --rotate normal --output DP1 --off --output HDMI1 --mode 1920x1200 --pos 0x0 --rotate normal --output DP2 --mode 1920x1200 --pos 1920x0 --rotate normal --output HDMI2 --off
    elif [ $LAYOUT == "one_mon" ]; then
        xrandr --output eDP1 --primary --mode 1920x1080 --pos 1920x0 --rotate normal --output DP1 --off --output HDMI1 --mode 1920x1080 --pos 0x0 --rotate normal --output DP2 --off --output HDMI2 --off
    elif [ $LAYOUT == "no_mon" ]; then
        xrandr --output eDP-1 --primary --mode 1920x1200 --pos 0x0 --rotate normal --output DP-1 --off --output HDMI-1 --off --output DP-2 --off --output DP-3 --off --output DP-4 --off --output DP-2-5 --off --output DP-2-5-5 --off --output DP-2-6 --off --output DP-2-6-6 --off
        # xrandr --output eDP1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output DP1 --off --output DP2 --off --output HDMI1 --off --output HDMI2 --off
    else
        exit 1
    fi
}

create_i3_conf() {
    # create new i3 config based on $LAYOUT
    _i3_pid=$(pgrep i3)
    _i3_socket="/run/user/$_uid/i3/ipc-socket.$_i3_pid"
    /home/$_user/.local/bin/i3_config_gen.py $LAYOUT $_user
    i3-msg -s ${_i3_socket} reload 2>&1
    i3-msg -s ${_i3_socket} restart 2>&1
}

reload_polybar() {
    # reload polybar to use all available outputs
    /home/$_user/.local/bin/polybar-launch.sh
}

reload_dunst() {
    ln -sf $HOME/.config/dunst/dunstrc-$LAYOUT $HOME/.config/dunst/dunstrc
    pkill dunst
}

set_wallpaper() {
    # set wallpaper based on number of active displays
    /home/$_user/.local/bin/set-wallpaper.sh
}

misc_config() {
    if [ $LAYOUT == "two_mon" ]; then
        brillo -S 100
        manage_picom start
    elif [ $LAYOUT == "one_mon" ]; then
        brillo -S 100
        manage_picom start
    elif [ $LAYOUT == "no_mon" ]; then
        brillo -S 25
        manage_picom stop
    else
        exit 1
    fi
    setxkbmap gb
    systemctl restart redshift-gtk --user
}

create_i3_conf
reload_polybar
set_wallpaper
misc_config

function tidyup {
    # set the status back
    sleep 1
    jq -n '{ "running": "false" }' | tee $_STATUSFILE
}

trap tidyup EXIT
