#!/usr/bin/env bash
# Cygnus-Ubuntu GDM Tokyo Night Theme
# Modifies the Yaru gresource used by GDM

set -e

# Get actual user home even when run with sudo
if [ -n "$SUDO_USER" ]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    USER_HOME="$HOME"
fi

WORKDIR="/tmp/gdm-tokyonight-$$"
GRESOURCE="/usr/share/gnome-shell/theme/Yaru/gnome-shell-theme.gresource"
WALLPAPER="$USER_HOME/.config/cygnus-ubuntu/wallpapers/tokyonight_original.png"

echo "Cygnus-Ubuntu GDM Tokyo Night Theme"
echo "===================================="
echo "Target: $GRESOURCE"

# Check dependencies
if ! command -v glib-compile-resources &> /dev/null; then
    echo "Installing required tools..."
    apt-get install -y libglib2.0-dev-bin
fi

# Check wallpaper exists
if [ ! -f "$WALLPAPER" ]; then
    echo "Error: Wallpaper not found at $WALLPAPER"
    exit 1
fi

# Backup original gresource
if [ ! -f "${GRESOURCE}.orig" ]; then
    echo "Creating backup of original gresource..."
    cp "$GRESOURCE" "${GRESOURCE}.orig"
fi

# Copy wallpaper to system location
echo "Copying wallpaper..."
mkdir -p /usr/share/backgrounds/cygnus-ubuntu
cp -f "$WALLPAPER" /usr/share/backgrounds/cygnus-ubuntu/login.png
chmod 644 /usr/share/backgrounds/cygnus-ubuntu/login.png

# Create working directory
mkdir -p "$WORKDIR"
cd "$WORKDIR"

echo "Extracting gresource (this may take a moment)..."
# Extract all resources maintaining directory structure
for r in $(gresource list "$GRESOURCE"); do
    dir=$(dirname "${r#/org/gnome/shell/}")
    mkdir -p "$dir"
    gresource extract "$GRESOURCE" "$r" > "${r#/org/gnome/shell/}"
done

echo "Applying Tokyo Night theme..."

# Create the Tokyo Night CSS additions
TOKYO_CSS=$(cat << 'TOKYONIGHT'

/* ═══════════════════════════════════════════════════════════════ */
/* CYGNUS-UBUNTU TOKYO NIGHT THEME FOR GDM                         */
/* ═══════════════════════════════════════════════════════════════ */

/* Login screen background */
#lockDialogGroup {
    background: #1a1b26 url(file:///usr/share/backgrounds/cygnus-ubuntu/login.png) !important;
    background-size: cover !important;
    background-position: center !important;
}

/* Login Dialog */
.login-dialog {
    background-color: transparent !important;
}

/* Password Input Field */
.login-dialog StEntry,
.login-dialog-prompt-entry {
    background-color: rgba(26, 27, 38, 0.9) !important;
    color: #c0caf5 !important;
    border: 2px solid #7aa2f7 !important;
    border-radius: 8px !important;
    padding: 12px 16px !important;
}

.login-dialog StEntry:hover,
.login-dialog-prompt-entry:hover {
    background-color: rgba(36, 40, 59, 0.95) !important;
    border-color: #7aa2f7 !important;
}

.login-dialog StEntry:focus,
.login-dialog-prompt-entry:focus {
    background-color: rgba(26, 27, 38, 0.95) !important;
    border-color: #bb9af7 !important;
    box-shadow: 0 0 0 2px rgba(122, 162, 247, 0.3) !important;
}

/* Placeholder text */
.login-dialog StEntry StLabel.hint-text,
.login-dialog-prompt-entry StLabel.hint-text {
    color: #565f89 !important;
}

/* Login Buttons */
.login-dialog-button,
.modal-dialog-button {
    background-color: rgba(26, 27, 38, 0.8) !important;
    color: #c0caf5 !important;
    border: 1px solid #7aa2f7 !important;
    border-radius: 8px !important;
}

.login-dialog-button:hover,
.modal-dialog-button:hover {
    background-color: rgba(122, 162, 247, 0.3) !important;
}

.login-dialog-button:focus,
.modal-dialog-button:focus {
    border-color: #bb9af7 !important;
}

/* User list */
.login-dialog-user-list-item {
    background-color: rgba(26, 27, 38, 0.6) !important;
    border-radius: 12px !important;
    padding: 12px !important;
    border: 1px solid transparent !important;
}

.login-dialog-user-list-item:hover,
.login-dialog-user-list-item:focus {
    background-color: rgba(36, 40, 59, 0.8) !important;
    border-color: #7aa2f7 !important;
}

.login-dialog-user-list-item:selected {
    background-color: rgba(122, 162, 247, 0.2) !important;
    border-color: #7aa2f7 !important;
}

.login-dialog-username,
.login-dialog-user-list-item .login-dialog-username {
    color: #c0caf5 !important;
}

.login-dialog-user-realname {
    color: #565f89 !important;
}

/* Error/Warning messages */
.login-dialog-message,
.login-dialog-message-warning {
    color: #f7768e !important;
}

.login-dialog-message-hint {
    color: #565f89 !important;
}

/* Session/Power buttons */
.login-dialog-session-list-button,
.login-dialog-not-listed-button {
    color: #7aa2f7 !important;
}

.login-dialog-not-listed-label {
    color: #c0caf5 !important;
}
TOKYONIGHT
)

# Append to gdm.css
if [ -f "$WORKDIR/theme/gdm.css" ]; then
    echo "$TOKYO_CSS" >> "$WORKDIR/theme/gdm.css"
    echo "  - Modified theme/gdm.css"
fi

# Append to all gnome-shell CSS files (for consistency)
for css in "$WORKDIR"/theme/Yaru/gnome-shell*.css; do
    if [ -f "$css" ]; then
        echo "$TOKYO_CSS" >> "$css"
        echo "  - Modified $(basename "$css")"
    fi
done

echo "Creating gresource XML..."

# Create the gresource XML with proper structure
cat > "$WORKDIR/gnome-shell-theme.gresource.xml" << 'XMLHEADER'
<?xml version="1.0" encoding="UTF-8"?>
<gresources>
  <gresource prefix="/org/gnome/shell">
XMLHEADER

# Add all extracted files
find "$WORKDIR" -type f ! -name "*.xml" | sort | while read -r file; do
    rel_path="${file#$WORKDIR/}"
    echo "    <file>$rel_path</file>" >> "$WORKDIR/gnome-shell-theme.gresource.xml"
done

cat >> "$WORKDIR/gnome-shell-theme.gresource.xml" << 'XMLFOOTER'
  </gresource>
</gresources>
XMLFOOTER

echo "Compiling new gresource..."
glib-compile-resources --sourcedir="$WORKDIR" "$WORKDIR/gnome-shell-theme.gresource.xml"

echo "Installing new gresource..."
cp "$WORKDIR/gnome-shell-theme.gresource" "$GRESOURCE"

# Cleanup
rm -rf "$WORKDIR"

echo ""
echo "✓ Done! Tokyo Night theme applied to GDM."
echo ""
echo "To see changes:"
echo "  - Log out and back in, or"
echo "  - Reboot: sudo reboot"
echo ""
echo "To restore original:"
echo "  sudo cp ${GRESOURCE}.orig $GRESOURCE"
