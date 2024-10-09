#!/usr/bin/env bash

rofi_dir="~/.config/rofi"
uptime=$(uptime -p | sed -e 's/up //g')

rofi_command="rofi -no-config -theme ${rofi_dir}/powermenu.rasi"

# Options
shutdown="shutdown"
reboot="restart"
lock="lock"
hibernate="hibernate"
suspend="suspend"
logout="logout"

# Confirmation
confirm_exit() {
    rofi -dmenu \
        -i \
        -no-fixed-num-lines \
        -p "are you sure? [yes/no]:  " \
        -theme ${rofi_dir}/confirm.rasi
}

# Message
msg() {
    rofi -theme "${rofi_dir}/message.rasi" -e "available options: [yes/y] / [no/n]"
}

# Variable passed to rofi
options="$lock\n$hibernate\n$suspend\n$logout\n$reboot\n$shutdown"

chosen="$(echo -e "$options" | $rofi_command -p "Uptime: $uptime" -dmenu -selected-row 0)"
case $chosen in
    $shutdown)
        ans=$(confirm_exit &)
        if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
            systemctl poweroff
        elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
            exit 0
        else
            msg
        fi
        ;;
    $reboot)
        ans=$(confirm_exit &)
        if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
            systemctl reboot
        elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
            exit 0
        else
            msg
        fi
        ;;
    $hibernate)
        ans=$(confirm_exit &)
        if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
            /usr/bin/light-locker-command -l &
            systemctl hibernate
        elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
            exit 0
        else
            msg
        fi
        ;;
    $lock)
        /usr/bin/light-locker-command -l
        ;;
    $suspend)
        ans=$(confirm_exit &)
        if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
            /usr/bin/light-locker-command -l &
            systemctl suspend
        elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
            exit 0
        else
            msg
        fi
        ;;
    $logout)
        ans=$(confirm_exit &)
        if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
            i3-msg exit
        elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
            exit 0
        else
            msg
        fi
        ;;
esac
