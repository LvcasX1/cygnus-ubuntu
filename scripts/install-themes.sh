#!/bin/bash
# Cygnus-Ubuntu: GTK/Icon/Cursor Themes Installation
# Part of Cygnus-Ubuntu Installer
#
# Installs visual themes for GTK applications

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_warning() { echo -e "${YELLOW}! $1${NC}"; }
print_info() { echo -e "${BLUE}→ $1${NC}"; }

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Theme directories
THEMES_DIR="$HOME/.themes"
ICONS_DIR="$HOME/.icons"
FONTS_DIR="$HOME/.local/share/fonts"

mkdir -p "$THEMES_DIR" "$ICONS_DIR" "$FONTS_DIR"

# Install Flat-Remix GTK Theme
install_flat_remix_gtk() {
    print_info "Installing Flat-Remix GTK theme..."

    if [[ -d "$THEMES_DIR/Flat-Remix-GTK-Blue-Dark" ]]; then
        print_info "Flat-Remix GTK theme already installed"
        return
    fi

    # Clone and install
    git clone --depth 1 https://github.com/daniruiz/flat-remix-gtk.git /tmp/flat-remix-gtk
    cp -r /tmp/flat-remix-gtk/themes/Flat-Remix-GTK-Blue-Dark "$THEMES_DIR/"
    cp -r /tmp/flat-remix-gtk/themes/Flat-Remix-GTK-Blue-Darker "$THEMES_DIR/" 2>/dev/null || true
    rm -rf /tmp/flat-remix-gtk

    print_success "Flat-Remix GTK theme installed"
}

# Install Flat-Remix Icon Theme
install_flat_remix_icons() {
    print_info "Installing Flat-Remix icon theme..."

    if [[ -d "$ICONS_DIR/Flat-Remix-Blue-Dark" ]]; then
        print_info "Flat-Remix icons already installed"
        return
    fi

    # Clone and install
    git clone --depth 1 https://github.com/daniruiz/flat-remix.git /tmp/flat-remix-icons
    cp -r /tmp/flat-remix-icons/Flat-Remix-Blue-Dark "$ICONS_DIR/"
    cp -r /tmp/flat-remix-icons/Flat-Remix-Blue-Light "$ICONS_DIR/" 2>/dev/null || true
    rm -rf /tmp/flat-remix-icons

    print_success "Flat-Remix icon theme installed"
}

# Install Bibata Cursor Theme
install_bibata_cursor() {
    print_info "Installing Bibata cursor theme..."

    if [[ -d "$ICONS_DIR/Bibata-Modern-Ice" ]]; then
        print_info "Bibata cursor already installed"
        return
    fi

    # Get latest release
    BIBATA_VERSION=$(curl -s "https://api.github.com/repos/ful1e5/Bibata_Cursor/releases/latest" | jq -r '.tag_name')
    wget -q "https://github.com/ful1e5/Bibata_Cursor/releases/download/${BIBATA_VERSION}/Bibata-Modern-Ice.tar.xz" -O /tmp/bibata.tar.xz

    tar -xf /tmp/bibata.tar.xz -C "$ICONS_DIR/"
    rm /tmp/bibata.tar.xz

    print_success "Bibata cursor theme installed"
}

# Install Catppuccin themes (alternative option)
install_catppuccin() {
    print_info "Installing Catppuccin GTK theme..."

    if [[ -d "$THEMES_DIR/catppuccin-mocha-blue-standard+default" ]]; then
        print_info "Catppuccin theme already installed"
        return
    fi

    # Download Catppuccin Mocha
    CATT_VERSION="v1.0.3"
    wget -q "https://github.com/catppuccin/gtk/releases/download/${CATT_VERSION}/catppuccin-mocha-blue-standard+default.zip" -O /tmp/catppuccin.zip
    unzip -o /tmp/catppuccin.zip -d "$THEMES_DIR/"
    rm /tmp/catppuccin.zip

    print_success "Catppuccin theme installed"
}

# Apply GTK settings via gsettings
apply_gtk_settings() {
    print_info "Applying GTK settings..."

    # GTK theme
    gsettings set org.gnome.desktop.interface gtk-theme 'Flat-Remix-GTK-Blue-Dark' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface icon-theme 'Flat-Remix-Blue-Dark' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice' 2>/dev/null || true
    gsettings set org.gnome.desktop.interface cursor-size 24 2>/dev/null || true

    # Dark mode preference
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true

    print_success "GTK settings applied"
}

# Set cursor for Hyprland
configure_hyprland_cursor() {
    print_info "Configuring Hyprland cursor..."

    # Create/update cursor config
    CURSOR_CONF="$HOME/.config/hypr/configs/Cursor.conf"

    if [[ -f "$CURSOR_CONF" ]]; then
        # Update existing
        sed -i 's/XCURSOR_THEME=.*/XCURSOR_THEME=Bibata-Modern-Ice/' "$CURSOR_CONF" 2>/dev/null || true
        sed -i 's/XCURSOR_SIZE=.*/XCURSOR_SIZE=24/' "$CURSOR_CONF" 2>/dev/null || true
    fi

    # Set environment variables
    export XCURSOR_THEME="Bibata-Modern-Ice"
    export XCURSOR_SIZE=24

    print_success "Hyprland cursor configured"
}

# Main
main() {
    echo ""
    print_info "═══════════════════════════════════════════════════════════"
    print_info "  Cygnus-Ubuntu Theme Installation"
    print_info "═══════════════════════════════════════════════════════════"
    echo ""

    install_flat_remix_gtk
    install_flat_remix_icons
    install_bibata_cursor
    apply_gtk_settings
    configure_hyprland_cursor

    # Optional: Catppuccin
    echo ""
    read -p "Also install Catppuccin theme (alternative)? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_catppuccin
    fi

    echo ""
    print_success "Theme installation complete!"
    print_info "Log out and back in for all changes to take effect."
}

main "$@"
