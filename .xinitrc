#!/bin/bash
# Only proceed if X is running
if [ -n "$DISPLAY" ]; then
    # Find the internal (built-in) display (typically named "eDP" or "LVDS")
    internal_monitor=$(xrandr --query | grep " connected" | grep -E "eDP|LVDS" | cut -d" " -f1 | head -n 1)

    if [ -n "$internal_monitor" ]; then
        # Set the built-in display to 1920x1080 @ 60Hz (common for T480)
        xrandr --output "$internal_monitor" --mode 1920x1080 --rate 60
    fi

    # Configure any external monitors (if connected) separately
    for monitor in $(xrandr --query | grep " connected" | cut -d" " -f1); do
        # Skip the internal display that we already configured
        if [ "$monitor" != "$internal_monitor" ]; then
            # Set external monitor to 2560x1440 @ 144Hz (adjust if needed)
            xrandr --output "$monitor" --mode 2560x1440 --rate 144
        fi
    done
fi

# Start bspwm
exec bspwm
