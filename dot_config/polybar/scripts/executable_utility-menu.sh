#!/usr/bin/env bash

rofi_dir="~/.config/rofi"
rofi_command="rofi -no-config -theme ${rofi_dir}/utility-menu.rasi"

gridscale_status() {
    if systemctl is-active openvpn-client@gridscale.service >/dev/null 2>&1; then
        gridscale_status="✅   gridscale vpn up"
    else
        gridscale_status="❌   gridscale vpn down"
    fi
}

vultr_status() {
    if systemctl is-active openvpn-client@vultr.service >/dev/null 2>&1; then
        vultr_status="✅   vultr vpn up"
    else
        vultr_status="❌   vultr vpn down"
    fi
}

code_giantswarm_status() {
    if systemctl --user is-active code-giantswarm.service >/dev/null 2>&1; then
        code_giantswarm_status="✅   code/giantswarm mounted"
    else
        code_giantswarm_status="❌   code/giantswarm unmounted"
    fi
}

code_personal_status() {
    if systemctl --user is-active code-personal.service >/dev/null 2>&1; then
        code_personal_status="✅   code/personal mounted"
    else
        code_personal_status="❌   code/personal unmounted"
    fi
}

gridscale_status
vultr_status
code_giantswarm_status
code_personal_status

# Options
gridscale="${gridscale_status}"
vultr="${vultr_status}"
code_giantswarm="${code_giantswarm_status}"
code_personal="${code_personal_status}"
polybar="🔁   reload polybar"

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
options="$gridscale\n$vultr\n$code_giantswarm\n$code_personal\n$polybar"

chosen="$(echo -e "$options" | $rofi_command -p "Utilities" -dmenu -selected-row 0)"
case $chosen in
    $gridscale)
        ans=$(confirm_exit &)
        if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
            systemctl is-active openvpn-client@gridscale.service >/dev/null 2>&1 \
                && sudo systemctl stop openvpn-client@gridscale.service \
                || sudo systemctl start openvpn-client@gridscale.service
        elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
            exit 0
        else
            msg
        fi
        ;;
    $vultr)
        ans=$(confirm_exit &)
        if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
            systemctl is-active openvpn-client@vultr.service >/dev/null 2>&1 \
                && sudo systemctl stop openvpn-client@vultr.service \
                || sudo systemctl start openvpn-client@vultr.service
        elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
            exit 0
        else
            msg
        fi
        ;;
    $code_giantswarm)
        ans=$(confirm_exit &)
        if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
            systemctl --user is-active code-giantswarm.service >/dev/null 2>&1 \
                && systemctl --user stop code-giantswarm.service \
                || systemctl --user start code-giantswarm.service
        elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
            exit 0
        else
            msg
        fi
        ;;
    $code_personal)
        ans=$(confirm_exit &)
        if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
            systemctl --user is-active code-personal.service >/dev/null 2>&1 \
                && systemctl --user stop code-personal.service \
                || systemctl --user start code-personal.service
        elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
            exit 0
        else
            msg
        fi
        ;;
    $polybar)
        ans=$(confirm_exit &)
        if [[ $ans == "yes" || $ans == "YES" || $ans == "y" || $ans == "Y" ]]; then
            /home/shw/.local/bin/polybar-launch.sh
        elif [[ $ans == "no" || $ans == "NO" || $ans == "n" || $ans == "N" ]]; then
            exit 0
        else
            msg
        fi
        ;;
esac
