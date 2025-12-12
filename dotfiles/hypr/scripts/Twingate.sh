#!/bin/bash
# Twingate VPN status and toggle script for Waybar

run_sudo() {
    local cmd="$1"
    local password=$(rofi -dmenu -password -config ~/.config/rofi/config-twingate.rasi)
    if [ -n "$password" ]; then
        echo "$password" | sudo -S $cmd 2>/dev/null
        return $?
    fi
    return 1
}

get_status() {
    # Check if twingate service is running
    if systemctl is-active --quiet twingate.service; then
        # Check connection status
        status=$(twingate status 2>/dev/null)
        if echo "$status" | grep -qi "online"; then
            echo '{"text": "󰖂", "tooltip": "Twingate: Connected\nLeft click: Disconnect\nRight click: Stop service", "class": "connected"}'
        else
            echo '{"text": "󰖂", "tooltip": "Twingate: Connecting...\nLeft click: Disconnect\nRight click: Stop service", "class": "connecting"}'
        fi
    else
        echo '{"text": "󰖃", "tooltip": "Twingate: Disconnected\nClick to connect", "class": "disconnected"}'
    fi
}

toggle() {
    if systemctl is-active --quiet twingate.service; then
        # Disconnect
        if run_sudo "twingate stop"; then
            notify-send -u normal -i network-vpn "Twingate" "VPN Disconnected"
        fi
    else
        # Start in terminal to show auth URL and handle browser opening
        wezterm start -- bash -c "sudo twingate start; echo 'Press Enter to close...'; read"
    fi
}

stop_service() {
    if run_sudo "systemctl stop twingate.service"; then
        notify-send -u normal -i network-vpn "Twingate" "Service stopped"
    fi
}

case "$1" in
    status)
        get_status
        ;;
    toggle)
        toggle
        ;;
    stop)
        stop_service
        ;;
    *)
        get_status
        ;;
esac
