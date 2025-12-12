#!/bin/bash
# Pop window out: if tiled, make floating and resize to 80% centered
# If already floating, return to tiled (size restores automatically)

is_floating=$(hyprctl activewindow -j | jq -r '.floating')

if [[ "$is_floating" == "true" ]]; then
    # Return to tiled
    hyprctl dispatch togglefloating
else
    # Make floating, resize, and center
    hyprctl dispatch togglefloating
    hyprctl dispatch resizeactive exact 80% 80%
    hyprctl dispatch centerwindow
fi
