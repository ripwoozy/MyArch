#!/bin/bash
# Author: ripwoozy
# Improved dual battery script for T480
# This script calculates the battery percentage and selects an emoji based on charging status.
# It works with TLP or other battery managers, as it reads from the system power supply interfaces.

BAT0_PATH="/sys/class/power_supply/BAT0"
BAT1_PATH="/sys/class/power_supply/BAT1"

# Function to fetch battery capacity and status from a given path
get_battery_info() {
    local path="$1"
    if [ -r "$path/capacity" ] && [ -r "$path/status" ]; then
        local capacity
        local status
        capacity=$(cat "$path/capacity")
        status=$(cat "$path/status")
        echo "$capacity $status"
    else
        echo "0 Unknown"
    fi
}

# Determine battery percentage and overall charging status
if [ -d "$BAT0_PATH" ] && [ -d "$BAT1_PATH" ]; then
    read BAT0_PERCENT BAT0_STATUS < <(get_battery_info "$BAT0_PATH")
    read BAT1_PERCENT BAT1_STATUS < <(get_battery_info "$BAT1_PATH")
    # Calculate the average battery percentage
    BAT_PERCENT=$(( (BAT0_PERCENT + BAT1_PERCENT) / 2 ))
    # If either battery is charging, consider the overall state as charging
    if [ "$BAT0_STATUS" = "Charging" ] || [ "$BAT1_STATUS" = "Charging" ]; then
        STATUS="Charging"
    else
        STATUS="Discharging"
    fi
elif [ -d "$BAT0_PATH" ]; then
    read BAT_PERCENT STATUS < <(get_battery_info "$BAT0_PATH")
elif [ -d "$BAT1_PATH" ]; then
    read BAT_PERCENT STATUS < <(get_battery_info "$BAT1_PATH")
else
    echo "No battery found"
    exit 1
fi

# Function to select an emoji based on battery percentage and state
select_emoji() {
    local percent=$1
    local state=$2
    local emoji=""
    if [ "$state" = "Charging" ]; then
        if [ "$percent" -eq 100 ]; then
            emoji="󰂄"
        elif [ "$percent" -ge 90 ]; then
            emoji="󰂋"
        elif [ "$percent" -ge 80 ]; then
            emoji="󰂊"
        elif [ "$percent" -ge 70 ]; then
            emoji="󰢞"
        elif [ "$percent" -ge 60 ]; then
            emoji="󰂉"
        elif [ "$percent" -ge 50 ]; then
            emoji="󰢝"
        elif [ "$percent" -ge 40 ]; then
            emoji="󰂈"
        elif [ "$percent" -ge 30 ]; then
            emoji="󰂇"
        elif [ "$percent" -ge 20 ]; then
            emoji="󰂆"
        elif [ "$percent" -ge 10 ]; then
            emoji="󰢜"
        else
            emoji="󰢟"
        fi
    else  # Discharging
        if [ "$percent" -eq 100 ]; then
            emoji="󰁹"
        elif [ "$percent" -ge 90 ]; then
            emoji="󰂂"
        elif [ "$percent" -ge 80 ]; then
            emoji="󰂁"
        elif [ "$percent" -ge 70 ]; then
            emoji="󰂀"
        elif [ "$percent" -ge 60 ]; then
            emoji="󰁿"
        elif [ "$percent" -ge 50 ]; then
            emoji="󰁾"
        elif [ "$percent" -ge 40 ]; then
            emoji="󰁽"
        elif [ "$percent" -ge 30 ]; then
            emoji="󰁼"
        elif [ "$percent" -ge 20 ]; then
            emoji="󰁻"
        elif [ "$percent" -ge 10 ]; then
            emoji="󰁺"
        else
            emoji="󱃍"
        fi
    fi
    echo "$emoji"
}

# Get the appropriate emoji for the current battery status
EMOJI=$(select_emoji "$BAT_PERCENT" "$STATUS")

# Output the emoji and battery percentage
echo "$EMOJI ${BAT_PERCENT}%"
