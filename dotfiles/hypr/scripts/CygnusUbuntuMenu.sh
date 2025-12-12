#!/bin/bash
# Cygnus-Ubuntu menu using rofi

# Use absolute paths to avoid $HOME expansion issues
HOME_DIR="${HOME:-/home/$(whoami)}"
SCRIPTS="$HOME_DIR/.config/hypr/scripts"
THEME="$HOME_DIR/.config/rofi/cygnus-ubuntu-menu.rasi"

menu() {
    local prompt="$1"
    local options="$2"
    # Count number of lines for dynamic height
    local line_count=$(echo -e "$options" | wc -l)
    echo -e "$options" | rofi -no-config -dmenu -i -p "$prompt" -theme "$THEME" \
        -theme-str "listview { lines: $line_count; }"
}

show_wallpaper() {
    WALLPAPER_DIR="$HOME_DIR/Pictures/wallpapers"
    WALLPAPER_THEME="$HOME_DIR/.config/rofi/cygnus-ubuntu-wallpaper.rasi"

    # Build entries with image paths for rofi icon display (format: name\0icon\x1fpath)
    entries=""
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        name=$(basename "$file")
        entries+="${name}\0icon\x1f${file}\n"
    done < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) | sort)
    entries+="  Back"

    choice=$(echo -e "$entries" | rofi -no-config -dmenu -i -p "Wallpaper" -theme "$WALLPAPER_THEME" -show-icons)

    case "$choice" in
        *Back*) show_setup ;;
        *)
            if [[ -n "$choice" && -f "$WALLPAPER_DIR/$choice" ]]; then
                # Set wallpaper on all monitors
                for monitor in $(hyprctl monitors -j | jq -r '.[].name'); do
                    swww img -o "$monitor" "$WALLPAPER_DIR/$choice" --transition-type grow --transition-pos center
                done
                notify-send "Wallpaper" "Changed to $choice"
            fi
            ;;
    esac
}

show_setup() {
    choice=$(menu "Setup" "󰖩  WiFi\n󰕾  Audio\n󰃟  Brightness\n󰌆  Keyboard RGB\n󰸉  Wallpaper\n󰍹  Displays\n󰒓  Settings\n󰌍  Keybindings\n  Back")
    case "$choice" in
        *WiFi*) nm-connection-editor ;;
        *Audio*) pavucontrol ;;
        *Brightness*)
            level=$(menu "Brightness" "100%\n75%\n50%\n25%\n10%")
            [[ -n "$level" ]] && brightnessctl set "$level"
            ;;
        *"Keyboard RGB"*) $SCRIPTS/KeyboardRGB.sh ;;
        *Wallpaper*) show_wallpaper ;;
        *Displays*) nwg-displays ;;
        *Settings*) gnome-control-center ;;
        *Keybindings*) $SCRIPTS/KeyHints.sh ;;
        *Back*) show_main ;;
    esac
}

show_capture() {
    choice=$(menu "Capture" "󰹑  Screenshot\n󰕧  Screen Area\n󱄄  Active Window\n󰃽  In 5 seconds\n  Back")
    case "$choice" in
        *"Screenshot"*) sleep 0.3 && $SCRIPTS/ScreenShot.sh --now ;;
        *"Screen Area"*) sleep 0.3 && $SCRIPTS/ScreenShot.sh --area ;;
        *"Active Window"*) sleep 0.3 && $SCRIPTS/ScreenShot.sh --active ;;
        *"5 seconds"*) $SCRIPTS/ScreenShot.sh --in5 ;;
        *Back*) show_main ;;
    esac
}

show_power_profile() {
    current=$(powerprofilesctl get)
    choice=$(menu "Power Profile [$current]" "󰓅  Performance\n󰾅  Balanced\n󰾆  Power Saver\n  Back")
    case "$choice" in
        *Performance*) powerprofilesctl set performance && notify-send "Power Profile" "Set to Performance" ;;
        *Balanced*) powerprofilesctl set balanced && notify-send "Power Profile" "Set to Balanced" ;;
        *"Power Saver"*) powerprofilesctl set power-saver && notify-send "Power Profile" "Set to Power Saver" ;;
        *Back*) show_toggle ;;
    esac
}

show_toggle() {
    choice=$(menu "Toggle" "󰖨  Nightlight\n󰖲  Waybar\n󰒲  Idle Lock\n󰂵  Animations\n󰡴  Power Profile\n  Back")
    case "$choice" in
        *Nightlight*) $SCRIPTS/Hyprsunset.sh toggle 2>/dev/null || notify-send "Nightlight toggled" ;;
        *Waybar*) pkill -SIGUSR1 waybar ;;
        *"Idle Lock"*) $SCRIPTS/Hypridle.sh 2>/dev/null || notify-send "Idle lock toggled" ;;
        *Animations*) $SCRIPTS/Animations.sh ;;
        *"Power Profile"*) show_power_profile ;;
        *Back*) show_main ;;
    esac
}

show_apps() {
    bash "$HOME_DIR/.config/hypr/scripts/AppLauncher.sh"
}

show_system() {
    choice=$(menu "System" "󰌾  Lock\n󰤄  Suspend\n󰜉  Restart\n󰐥  Shutdown\n󰗽  Logout\n  Back")
    case "$choice" in
        *Lock*) $SCRIPTS/LockScreen.sh ;;
        *Suspend*) systemctl suspend ;;
        *Restart*) systemctl reboot ;;
        *Shutdown*) systemctl poweroff ;;
        *Logout*) hyprctl dispatch exit 0 ;;
        *Back*) show_main ;;
    esac
}

show_main() {
    choice=$(menu "Menu" "󰀻  Apps\n󰒓  Setup\n󰹑  Capture\n󰔡  Toggle\n󰐥  System")
    case "$choice" in
        *Apps*) show_apps ;;
        *Setup*) show_setup ;;
        *Capture*) show_capture ;;
        *Toggle*) show_toggle ;;
        *System*) show_system ;;
    esac
}

show_main
