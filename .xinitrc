# Check if X server is running
if [ -n "$DISPLAY" ]; then
    # Iterate over connected monitors
    for monitor in $(xrandr -q | grep -w 'connected' | cut -d' ' -f1); do
        # Check if resolution is already set to 2560x1440
        if xrandr | grep -q "$monitor connected"; then
            if ! xrandr | grep -q "2560x1440"; then
                xrandr --output "$monitor" --mode 2560x1440
            fi

            # Check if refresh rate is already set to 144 Hz
            current_refresh_rate=$(xrandr --verbose | awk -v monitor="$monitor" '/^\s*144.00\s*$/ {getline; if ($1 == monitor) print $2}')
            if [ "$current_refresh_rate" != "hertz" ]; then
                xrandr --output "$monitor" --mode 2560x1440 --rate 144
            fi
        fi
    done
fi

bspwm
