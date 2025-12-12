#!/usr/bin/env bash
# Cygnus-Ubuntu GDM Setup - Tokyo Night Theme
# Sets GDM login screen background

set -e

# Get the actual user's home even if run with sudo
if [ -n "$SUDO_USER" ]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    USER_HOME="$HOME"
fi

# Tokyo Night wallpaper
WALLPAPER="$USER_HOME/.config/cygnus-ubuntu/wallpapers/tokyonight_original.png"

if [ ! -f "$WALLPAPER" ]; then
    echo "Error: Wallpaper not found at $WALLPAPER"
    exit 1
fi

echo "Cygnus-Ubuntu GDM Setup - Tokyo Night Theme"
echo "============================================"
echo "Wallpaper: $WALLPAPER"
echo ""

# GDM uses the gnome-shell theme
# We'll copy the wallpaper and set it via dconf for the gdm user

# Copy wallpaper to a system location GDM can access
echo "Copying wallpaper to system location..."
sudo mkdir -p /usr/share/backgrounds/cygnus-ubuntu
sudo cp -f "$WALLPAPER" /usr/share/backgrounds/cygnus-ubuntu/login.png
sudo chmod 644 /usr/share/backgrounds/cygnus-ubuntu/login.png

# Set GDM background using dconf (for gdm user)
echo "Setting GDM background..."

# Create a script that will set the background for the gdm user
sudo tee /tmp/gdm-setup.sh > /dev/null << 'GDMSCRIPT'
#!/bin/bash
export $(dbus-launch)
GSETTINGS_BACKEND=dconf gsettings set org.gnome.desktop.background picture-uri "file:///usr/share/backgrounds/cygnus-ubuntu/login.png"
GSETTINGS_BACKEND=dconf gsettings set org.gnome.desktop.background picture-uri-dark "file:///usr/share/backgrounds/cygnus-ubuntu/login.png"
GSETTINGS_BACKEND=dconf gsettings set org.gnome.desktop.screensaver picture-uri "file:///usr/share/backgrounds/cygnus-ubuntu/login.png"
GDMSCRIPT

sudo chmod +x /tmp/gdm-setup.sh
sudo -u gdm dbus-launch /tmp/gdm-setup.sh 2>/dev/null || true
sudo rm /tmp/gdm-setup.sh

# Alternative: Modify GDM CSS directly (more reliable)
GDM_CSS="/usr/share/gnome-shell/theme/Yaru/gnome-shell.css"
GDM_CSS_ALT="/usr/share/gnome-shell/theme/gnome-shell.css"

for css_file in "$GDM_CSS" "$GDM_CSS_ALT"; do
    if [ -f "$css_file" ]; then
        echo "Found GDM CSS at: $css_file"

        # Backup original
        if [ ! -f "${css_file}.backup" ]; then
            sudo cp "$css_file" "${css_file}.backup"
        fi

        # Check if our custom block already exists
        if ! grep -q "cygnus-ubuntu-login" "$css_file"; then
            # Append our custom CSS
            sudo tee -a "$css_file" > /dev/null << 'CSSEOF'

/* cygnus-ubuntu-login - Tokyo Night theme */
#lockDialogGroup {
    background: url(file:///usr/share/backgrounds/cygnus-ubuntu/login.png);
    background-size: cover;
    background-position: center;
}
CSSEOF
            echo "Added Tokyo Night background to GDM CSS"
        else
            echo "Tokyo Night background already configured"
        fi
        break
    fi
done

echo ""
echo "Done! Changes will apply on next login/reboot."
echo ""
echo "Note: GDM theming can be tricky. If background doesn't show:"
echo "  - Try: sudo systemctl restart gdm"
echo "  - Or reboot the system"
