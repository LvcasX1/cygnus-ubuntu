#!/bin/bash
# Toggle Waybar visibility

if pgrep -x waybar > /dev/null; then
    pkill -x waybar
else
    waybar -c ~/.config/waybar/cygnus-ubuntu-config.jsonc -s ~/.config/waybar/cygnus-ubuntu-style.css &
fi
