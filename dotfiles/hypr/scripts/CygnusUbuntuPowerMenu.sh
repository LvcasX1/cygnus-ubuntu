#!/bin/bash
# Cygnus-Ubuntu power menu using rofi

# Use absolute paths to avoid $HOME expansion issues
HOME_DIR="${HOME:-/home/$(whoami)}"
SCRIPTS="$HOME_DIR/.config/hypr/scripts"
THEME="$HOME_DIR/.config/rofi/cygnus-ubuntu-menu.rasi"

choice=$(echo -e "󰌾  Lock\n󰤄  Suspend\n󰜉  Restart\n󰐥  Shutdown\n󰗽  Logout" | rofi -no-config -dmenu -i -p "Power" -theme "$THEME")

case "$choice" in
    *Lock*) $SCRIPTS/LockScreen.sh ;;
    *Suspend*) systemctl suspend ;;
    *Restart*) systemctl reboot ;;
    *Shutdown*) systemctl poweroff ;;
    *Logout*) hyprctl dispatch exit 0 ;;
esac
