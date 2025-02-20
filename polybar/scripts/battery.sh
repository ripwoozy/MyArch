#!/bin/bash
BAT0_PATH="/sys/class/power_supply/BAT0"
BAT1_PATH="/sys/class/power_supply/BAT1"

# Check if both battery paths exist and set defaults
if [ -d "$BAT0_PATH" ] && [ -d "$BAT1_PATH" ]; then
    BAT0_PERCENT=$(cat "$BAT0_PATH/capacity")
    BAT1_PERCENT=$(cat "$BAT1_PATH/capacity")
    BAT0_STATUS=$(cat "$BAT0_PATH/status")
    BAT1_STATUS=$(cat "$BAT1_PATH/status")

    # Calculate average battery percentage
    BAT_PERCENT=$(( (BAT0_PERCENT + BAT1_PERCENT) / 2 ))

    # Determine charging status
    if [ "$BAT0_STATUS" = "Charging" ] || [ "$BAT1_STATUS" = "Charging" ]; then
        STATUS="Charging"
    else
        STATUS="Discharging"
    fi
elif [ -d "$BAT0_PATH" ]; then
    BAT_PERCENT=$(cat "$BAT0_PATH/capacity")
    STATUS=$(cat "$BAT0_PATH/status")
elif [ -d "$BAT1_PATH" ]; then
    BAT_PERCENT=$(cat "$BAT1_PATH/capacity")
    STATUS=$(cat "$BAT1_PATH/status")
else
    echo "No battery found"
    exit 1
fi

if [ "$STATUS" = "Charging" ]; then
        if [ "$BAT_PERCENT" -eq 100 ]; then
            EMOJI="󰂄"
        elif [ "$BAT_PERCENT" -ge 90 ]; then
            EMOJI="󰂋"
        elif [ "$BAT_PERCENT" -ge 80 ]; then
            EMOJI="󰂊"
        elif [ "$BAT_PERCENT" -ge 70 ]; then
            EMOJI="󰢞"
        elif [ "$BAT_PERCENT" -ge 60 ]; then
            EMOJI="󰂉"
        elif [ "$BAT_PERCENT" -ge 50 ]; then
            EMOJI="󰢝"
        elif [ "$BAT_PERCENT" -ge 40 ]; then
            EMOJI="󰂈"
        elif [ "$BAT_PERCENT" -ge 30 ]; then
            EMOJI="󰂇"
        elif [ "$BAT_PERCENT" -ge 20 ]; then
            EMOJI="󰂆"
        elif [ "$BAT_PERCENT" -ge 10 ]; then
            EMOJI="󰢜"
        else
            EMOJI="󰢟"
        fi
else
        if [ "$BAT_PERCENT" -eq 100 ]; then
            EMOJI="󰁹" 
        elif [ "$BAT_PERCENT" -ge 90 ]; then
            EMOJI="󰂂" 
        elif [ "$BAT_PERCENT" -ge 80 ]; then
            EMOJI="󰂁"
        elif [ "$BAT_PERCENT" -ge 70 ]; then
            EMOJI="󰂀"
        elif [ "$BAT_PERCENT" -ge 60 ]; then
            EMOJI="󰁿"
        elif [ "$BAT_PERCENT" -ge 50 ]; then
            EMOJI="󰁾"
        elif [ "$BAT_PERCENT" -ge 40 ]; then
            EMOJI="󰁽"
        elif [ "$BAT_PERCENT" -ge 30 ]; then
            EMOJI="󰁼"
        elif [ "$BAT_PERCENT" -ge 20 ]; then
            EMOJI="󰁻"
        elif [ "$BAT_PERCENT" -ge 10 ]; then
            EMOJI="󰁺"
        else
            EMOJI="󱃍"
        fi
fi

echo "$EMOJI ${BAT_PERCENT}%"