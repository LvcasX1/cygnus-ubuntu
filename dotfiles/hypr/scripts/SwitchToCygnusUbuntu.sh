#!/bin/bash
# Switch to Cygnus-Ubuntu configuration
# Run this script to enable Cygnus-Ubuntu look and keybindings

HYPR_DIR="$HOME/.config/hypr"
WAYBAR_DIR="$HOME/.config/waybar"
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)

echo "Switching to Cygnus-Ubuntu configuration..."

# Backup current hyprland.conf
if [ -f "$HYPR_DIR/hyprland.conf" ]; then
    cp "$HYPR_DIR/hyprland.conf" "$HYPR_DIR/hyprland.conf.backup.$BACKUP_DATE"
    echo "Backed up hyprland.conf"
fi

# Create new hyprland.conf that sources Cygnus-Ubuntu config
cat > "$HYPR_DIR/hyprland.conf" << 'EOF'
# Cygnus-Ubuntu Hyprland Configuration
# Original config backed up as hyprland.conf.backup.*
# To restore: cp ~/.config/hypr/hyprland.conf.backup.* ~/.config/hypr/hyprland.conf

source = ~/.config/hypr/cygnus-ubuntu/hyprland-cygnus-ubuntu.conf
EOF

echo "Updated hyprland.conf to use Cygnus-Ubuntu style"

# Restart waybar with Cygnus-Ubuntu config
pkill waybar
sleep 0.3
waybar -c "$WAYBAR_DIR/cygnus-ubuntu-config.jsonc" -s "$WAYBAR_DIR/cygnus-ubuntu-style.css" &
disown

echo "Started Waybar with Cygnus-Ubuntu theme"

# Reload Hyprland
hyprctl reload

echo ""
echo "Done! Cygnus-Ubuntu configuration is now active."
echo ""
echo "Key bindings summary:"
echo "  SUPER + D / SUPER + Space  - App launcher (rofi)"
echo "  SUPER + Return             - Terminal"
echo "  SUPER + W                  - Close window"
echo "  SUPER + F                  - Fullscreen"
echo "  SUPER + T                  - Toggle floating"
echo "  SUPER + 1-0                - Switch workspaces"
echo "  SUPER + SHIFT + 1-0        - Move window to workspace"
echo "  SUPER + Tab                - Next workspace"
echo "  SUPER + S                  - Scratchpad"
echo "  SUPER + G                  - Toggle group"
echo "  SUPER + CTRL + V           - Clipboard manager"
echo "  SUPER + /                  - Show all keybinds"
echo ""
echo "To restore your previous config:"
echo "  cp ~/.config/hypr/hyprland.conf.backup.$BACKUP_DATE ~/.config/hypr/hyprland.conf"
echo "  hyprctl reload"
