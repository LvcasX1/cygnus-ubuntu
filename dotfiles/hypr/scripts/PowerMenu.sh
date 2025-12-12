#!/bin/bash
# Power menu inspired by Omarchy

# Get current power profile
current_profile=$(powerprofilesctl get)
case "$current_profile" in
    performance) profile_icon="󱐋" ;;
    balanced) profile_icon="󰗑" ;;
    power-saver) profile_icon="󰌪" ;;
    *) profile_icon="󰐥" ;;
esac

options="󰌾  Lock\n󰤄  Suspend\n󰜉  Restart\n󰐥  Shutdown\n󰗽  Logout\n$profile_icon  Power Profile"

chosen=$(echo -e "$options" | rofi -dmenu -i -p "System" -normal-window -theme-str '
window {
    width: 300px;
    location: center;
    anchor: center;
    border-radius: 12px;
}
listview {
    lines: 6;
    spacing: 8px;
}
element {
    padding: 12px;
    border-radius: 8px;
}
entry {
    enabled: false;
}
inputbar {
    children: [prompt];
    padding: 12px;
}
prompt {
    font: "JetBrainsMono NF Bold 14";
}
')

case "$chosen" in
    *Lock*)
        $HOME/.config/hypr/scripts/LockScreen.sh
        ;;
    *Suspend*)
        systemctl suspend
        ;;
    *Restart*)
        systemctl reboot
        ;;
    *Shutdown*)
        systemctl poweroff
        ;;
    *Logout*)
        hyprctl dispatch exit 0
        ;;
    *"Power Profile"*)
        # Show power profile submenu
        current=$(powerprofilesctl get)
        profile_options="󱐋  Performance\n󰗑  Balanced\n󰌪  Power Saver"

        profile_chosen=$(echo -e "$profile_options" | rofi -dmenu -i -p "Power Profile ($current)" -normal-window -theme-str '
window {
    width: 300px;
    location: center;
    anchor: center;
    border-radius: 12px;
}
listview {
    lines: 3;
    spacing: 8px;
}
element {
    padding: 12px;
    border-radius: 8px;
}
entry {
    enabled: false;
}
inputbar {
    children: [prompt];
    padding: 12px;
}
prompt {
    font: "JetBrainsMono NF Bold 14";
}
')

        case "$profile_chosen" in
            *Performance*)
                powerprofilesctl set performance
                notify-send "Power Profile" "Set to Performance" -i battery-full-charged
                ;;
            *Balanced*)
                powerprofilesctl set balanced
                notify-send "Power Profile" "Set to Balanced" -i battery-good
                ;;
            *"Power Saver"*)
                powerprofilesctl set power-saver
                notify-send "Power Profile" "Set to Power Saver" -i battery-low
                ;;
        esac
        ;;
esac
