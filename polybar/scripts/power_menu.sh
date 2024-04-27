#!/bin/bash

options="󰌾 Lock\n󰍃 Logout\n󰖔 Suspend\n󰜉 Restart\n󰐥 Shutdown"

selected_option=$(echo -e "$options" | rofi -dmenu -i -p "Power Menu")

case $selected_option in
    "󰌾 Lock")
        betterlockscreen -l blur
        ;;
    "󰍃 Logout")
        killall bspwm
        ;;
    "󰖔 Suspend")
        systemctl suspend
        ;;
    "󰜉 Restart")
        systemctl reboot
        ;;
    "󰐥 Shutdown")
        systemctl poweroff
        ;;
    
    
    
    *)
        exit 1
        ;;
esac
