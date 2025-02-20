#!/bin/bash

# Terminate already running polybar instances
killall -q polybar

# Wait until all polybar processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do
    sleep 0.5
done

# Optional delay to let bspwm finish initializing
sleep 1

# Launch Polybar using the "main" bar configuration,
# capture output for debugging, and run in the background.
polybar -r main 2>&1 | tee -a /tmp/polybar.log &

# Give polybar a moment to start and check if it launched
sleep 2
if ! pgrep -u $UID -x polybar >/dev/null; then
    echo "Polybar failed to start. Check /tmp/polybar.log for details."
fi
