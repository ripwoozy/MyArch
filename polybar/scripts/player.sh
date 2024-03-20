#!/bin/bash

# Get the status using playerctl
status=$(playerctl status 2>/dev/null)

# Check if playerctl returned any status
if [ -z "$status" ]; then
    echo "No media player is currently running."
else
    case "$status" in
        "Playing")
            echo "󰒮   󰒭"
            ;;
        "Paused")
            echo "󰒮   󰒭"
            ;;
        *)
            echo "Player status: $status"
            ;;
    esac
fi
