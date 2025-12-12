#!/bin/bash
# Keyboard RGB control using asusctl

THEME="$HOME/.config/rofi/cygnus-ubuntu-menu.rasi"

menu() {
    echo -e "$2" | rofi -dmenu -i -p "$1" -theme "$THEME" -markup-rows
}

notify() {
    notify-send -e -u low -i "preferences-desktop-keyboard" "Keyboard RGB" "$1"
}

set_color() {
    asusctl aura static -c "$1"
    notify "$2"
}

show_colors() {
    choice=$(menu "Colors" "<span foreground='#ff0000'>󰝤</span>  Red\n<span foreground='#00ff00'>󰝤</span>  Green\n<span foreground='#0000ff'>󰝤</span>  Blue\n<span foreground='#ffff00'>󰝤</span>  Yellow\n<span foreground='#00ffff'>󰝤</span>  Cyan\n<span foreground='#ff00ff'>󰝤</span>  Magenta\n<span foreground='#ffffff'>󰝤</span>  White\n<span foreground='#ff8000'>󰝤</span>  Orange\n<span foreground='#8000ff'>󰝤</span>  Purple\n󰁍  Back")
    case "$choice" in
        *Red*) set_color "ff0000" "Red" ;;
        *Green*) set_color "00ff00" "Green" ;;
        *Blue*) set_color "0000ff" "Blue" ;;
        *Yellow*) set_color "ffff00" "Yellow" ;;
        *Cyan*) set_color "00ffff" "Cyan" ;;
        *Magenta*) set_color "ff00ff" "Magenta" ;;
        *White*) set_color "ffffff" "White" ;;
        *Orange*) set_color "ff8000" "Orange" ;;
        *Purple*) set_color "8000ff" "Purple" ;;
        *Back*) show_main ;;
    esac
}

show_effects() {
    choice=$(menu "Effects" "󰛐  Static\n󰊓  Breathe\n󰑓  Rainbow Cycle\n󰖝  Rainbow Wave\n󱐋  Pulse\n󰁍  Back")
    case "$choice" in
        *"Static"*) asusctl aura static -c 0000ff && notify "Static" ;;
        *"Breathe"*) asusctl aura breathe -c 0000ff -C ff0000 && notify "Breathe" ;;
        *"Rainbow Cycle"*) asusctl aura rainbow-cycle && notify "Rainbow Cycle" ;;
        *"Rainbow Wave"*) asusctl aura rainbow-wave && notify "Rainbow Wave" ;;
        *"Pulse"*) asusctl aura pulse -c 0000ff && notify "Pulse" ;;
        *Back*) show_main ;;
    esac
}

show_brightness() {
    choice=$(menu "Brightness" "󰃠  High\n󰃟  Medium\n󰃞  Low\n󰃝  Off\n󰁍  Back")
    case "$choice" in
        *High*) asusctl -k high && notify "Brightness: High" ;;
        *Medium*) asusctl -k med && notify "Brightness: Medium" ;;
        *Low*) asusctl -k low && notify "Brightness: Low" ;;
        *Off*) asusctl -k off && notify "Brightness: Off" ;;
        *Back*) show_main ;;
    esac
}

show_lightbar() {
    choice=$(menu "Lightbar" "󰔛  Enable\n󰔜  Disable\n󰁍  Back")
    case "$choice" in
        *Enable*)
            asusctl aura-power lightbar -a -b
            notify "Lightbar Enabled"
            ;;
        *Disable*)
            asusctl aura-power lightbar
            notify "Lightbar Disabled"
            ;;
        *Back*) show_main ;;
    esac
}

show_main() {
    choice=$(menu "Keyboard RGB" "󰏘  Colors\n󰑓  Effects\n󰃟  Brightness\n󰌌  Lightbar\n󰐥  Turn Off")
    case "$choice" in
        *Colors*) show_colors ;;
        *Effects*) show_effects ;;
        *Brightness*) show_brightness ;;
        *Lightbar*) show_lightbar ;;
        *"Turn Off"*) asusctl -k off && notify "Keyboard RGB Off" ;;
    esac
}

show_main
