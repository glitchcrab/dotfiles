#!/usr/bin/env bash

echo "settings default sink to usb audio"
pactl set-default-sink alsa_output.usb-Generic_USB_Audio-00.analog-stereo
