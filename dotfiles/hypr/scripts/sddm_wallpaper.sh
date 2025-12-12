#!/usr/bin/env bash
# Cygnus-Ubuntu SDDM Setup - Tokyo Night Theme
# Run WITHOUT sudo: ./sddm_wallpaper.sh
# The script will ask for sudo when needed

set -e

# ═══════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════
# Get the actual user's home even if run with sudo
if [ -n "$SUDO_USER" ]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    USER_HOME="$HOME"
fi

# Tokyo Night wallpaper (bundled with cygnus-ubuntu)
TOKYONIGHT_WALLPAPER="$USER_HOME/.config/cygnus-ubuntu/wallpapers/tokyonight_original.png"

# Fallback to current wallpaper if tokyonight doesn't exist
if [ -f "$TOKYONIGHT_WALLPAPER" ]; then
    WALLPAPER="$TOKYONIGHT_WALLPAPER"
elif [ -f "$USER_HOME/.config/hypr/wallpaper_effects/.wallpaper_current" ]; then
    WALLPAPER="$USER_HOME/.config/hypr/wallpaper_effects/.wallpaper_current"
else
    echo "Error: No wallpaper found"
    exit 1
fi

# SDDM theme directory
SDDM_THEMES="/usr/share/sddm/themes"
SDDM_THEME="$SDDM_THEMES/simple_sddm_2"
SDDM_CONF="$SDDM_THEME/theme.conf"

# ═══════════════════════════════════════════════════════════════
# TOKYO NIGHT COLOR PALETTE
# ═══════════════════════════════════════════════════════════════
TN_BG="#1a1b26"
TN_FG="#c0caf5"
TN_BLUE="#7aa2f7"
TN_PURPLE="#bb9af7"
TN_COMMENT="#565f89"

# ═══════════════════════════════════════════════════════════════
# CHECKS
# ═══════════════════════════════════════════════════════════════
if [ ! -d "$SDDM_THEME" ]; then
    echo "Error: SDDM theme not found at $SDDM_THEME"
    echo "Install simple_sddm_2 theme first"
    exit 1
fi

echo "Cygnus-Ubuntu SDDM Setup - Tokyo Night Theme"
echo "============================================="
echo "Wallpaper: $WALLPAPER"
echo "Theme: $SDDM_THEME"
echo ""

# ═══════════════════════════════════════════════════════════════
# APPLY CHANGES (requires sudo)
# ═══════════════════════════════════════════════════════════════
echo "Applying Tokyo Night colors to SDDM..."

sudo sed -i "s/HeaderTextColor=\"#.*\"/HeaderTextColor=\"$TN_FG\"/" "$SDDM_CONF"
sudo sed -i "s/DateTextColor=\"#.*\"/DateTextColor=\"$TN_FG\"/" "$SDDM_CONF"
sudo sed -i "s/TimeTextColor=\"#.*\"/TimeTextColor=\"$TN_BLUE\"/" "$SDDM_CONF"
sudo sed -i "s/DropdownSelectedBackgroundColor=\"#.*\"/DropdownSelectedBackgroundColor=\"$TN_BLUE\"/" "$SDDM_CONF"
sudo sed -i "s/SystemButtonsIconsColor=\"#.*\"/SystemButtonsIconsColor=\"$TN_PURPLE\"/" "$SDDM_CONF"
sudo sed -i "s/SessionButtonTextColor=\"#.*\"/SessionButtonTextColor=\"$TN_FG\"/" "$SDDM_CONF"
sudo sed -i "s/VirtualKeyboardButtonTextColor=\"#.*\"/VirtualKeyboardButtonTextColor=\"$TN_FG\"/" "$SDDM_CONF"
sudo sed -i "s/HighlightBackgroundColor=\"#.*\"/HighlightBackgroundColor=\"$TN_BLUE\"/" "$SDDM_CONF"
sudo sed -i "s/LoginFieldTextColor=\"#.*\"/LoginFieldTextColor=\"$TN_FG\"/" "$SDDM_CONF"
sudo sed -i "s/PasswordFieldTextColor=\"#.*\"/PasswordFieldTextColor=\"$TN_FG\"/" "$SDDM_CONF"
sudo sed -i "s/DropdownBackgroundColor=\"#.*\"/DropdownBackgroundColor=\"$TN_BG\"/" "$SDDM_CONF"
sudo sed -i "s/HighlightTextColor=\"#.*\"/HighlightTextColor=\"$TN_BG\"/" "$SDDM_CONF"
sudo sed -i "s/PlaceholderTextColor=\"#.*\"/PlaceholderTextColor=\"$TN_COMMENT\"/" "$SDDM_CONF"
sudo sed -i "s/UserIconColor=\"#.*\"/UserIconColor=\"$TN_PURPLE\"/" "$SDDM_CONF"
sudo sed -i "s/PasswordIconColor=\"#.*\"/PasswordIconColor=\"$TN_BLUE\"/" "$SDDM_CONF"

echo "Copying wallpaper..."
sudo mkdir -p "$SDDM_THEME/Backgrounds"
sudo cp -f "$WALLPAPER" "$SDDM_THEME/Backgrounds/default"
[ -f "$SDDM_THEME/Backgrounds/default.jpg" ] && sudo cp -f "$WALLPAPER" "$SDDM_THEME/Backgrounds/default.jpg"
[ -f "$SDDM_THEME/Backgrounds/default.png" ] && sudo cp -f "$WALLPAPER" "$SDDM_THEME/Backgrounds/default.png"

echo ""
echo "Done! SDDM is now themed with Tokyo Night."
echo "Changes will apply on next login screen."
