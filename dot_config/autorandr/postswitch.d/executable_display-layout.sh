#!/bin/bash

export DISPLAY=":0"
export XAUTHORITY="/home/shw/.Xauthority"
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"

/home/shw/.local/bin/display-layout.sh
