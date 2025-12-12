#!/bin/bash
# Cygnus-Ubuntu: Hyprland + Wayland Ecosystem Installation
# Part of Cygnus-Ubuntu Installer
#
# Based on: JaKooLit/Ubuntu-Hyprland (https://github.com/JaKooLit/Ubuntu-Hyprland)
# Adapted for Ubuntu 24.04

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

# Add required PPAs
print_info "Adding Hyprland PPA..."
if ! grep -q "hyprland-team/hyprland" /etc/apt/sources.list.d/*.list 2>/dev/null; then
    sudo add-apt-repository -y ppa:hyprland-team/hyprland
fi

# Add nwg-shell PPA for nwg-displays and nwg-look
print_info "Adding nwg-shell PPA..."
if ! grep -q "nwg-shell" /etc/apt/sources.list.d/*.list 2>/dev/null; then
    sudo add-apt-repository -y ppa:nwg-shell/nwg-shell
fi

# Update after adding PPAs
sudo apt update

# Core Hyprland packages
print_info "Installing Hyprland core packages..."
sudo apt install -y \
    hyprland \
    hyprlock \
    hypridle \
    hyprpicker \
    xdg-desktop-portal-hyprland

# Wayland utilities
print_info "Installing Wayland utilities..."
sudo apt install -y \
    wl-clipboard \
    cliphist \
    wtype \
    grim \
    slurp \
    swappy

# swww (wallpaper daemon) - install from GitHub if not in repos
if ! command -v swww &> /dev/null; then
    print_info "Installing swww..."
    if apt-cache show swww &> /dev/null; then
        sudo apt install -y swww
    else
        print_info "Building swww from source..."
        # Install Rust if needed
        if ! command -v cargo &> /dev/null; then
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            source "$HOME/.cargo/env"
        fi

        SWWW_VERSION=$(curl -s "https://api.github.com/repos/LGFae/swww/releases/latest" | jq -r '.tag_name')
        git clone --depth 1 --branch "$SWWW_VERSION" https://github.com/LGFae/swww.git /tmp/swww
        cd /tmp/swww
        cargo build --release
        sudo cp target/release/swww /usr/local/bin/
        sudo cp target/release/swww-daemon /usr/local/bin/
        cd - > /dev/null
        rm -rf /tmp/swww
    fi
fi

# wallust (color scheme generator)
if ! command -v wallust &> /dev/null; then
    print_info "Installing wallust..."
    if apt-cache show wallust &> /dev/null; then
        sudo apt install -y wallust
    else
        # Install from cargo
        if ! command -v cargo &> /dev/null; then
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            source "$HOME/.cargo/env"
        fi
        cargo install wallust
    fi
fi

# Waybar
print_info "Installing Waybar..."
sudo apt install -y waybar

# Rofi (wayland version)
print_info "Installing Rofi..."
sudo apt install -y rofi

# SwayNC (notification center)
print_info "Installing SwayNC..."
if apt-cache show swaync &> /dev/null; then
    sudo apt install -y swaync
else
    # Try alternative package name
    sudo apt install -y swaynotificationcenter || print_warning "SwayNC not found in repos"
fi

# Terminal emulators
print_info "Installing terminal emulators..."
sudo apt install -y \
    kitty \
    wezterm

# File manager
print_info "Installing file manager..."
sudo apt install -y nautilus

# System monitoring tools
print_info "Installing system monitoring tools..."
sudo apt install -y \
    btop \
    cava

# fastfetch (system info)
if ! command -v fastfetch &> /dev/null; then
    print_info "Installing fastfetch..."
    if apt-cache show fastfetch &> /dev/null; then
        sudo apt install -y fastfetch
    else
        # Install from GitHub releases
        FF_VERSION=$(curl -s "https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest" | jq -r '.tag_name')
        wget -q "https://github.com/fastfetch-cli/fastfetch/releases/download/${FF_VERSION}/fastfetch-linux-amd64.deb" -O /tmp/fastfetch.deb
        sudo dpkg -i /tmp/fastfetch.deb || sudo apt install -f -y
        rm /tmp/fastfetch.deb
    fi
fi

# Media and brightness controls
print_info "Installing media and brightness controls..."
sudo apt install -y \
    brightnessctl \
    playerctl \
    pamixer \
    pavucontrol

# Rofi menu script dependencies
print_info "Installing rofi menu dependencies..."
sudo apt install -y \
    yad \
    qalc \
    qalculate-gtk \
    gnome-control-center \
    nm-connection-editor \
    blueman

# nwg-shell tools
print_info "Installing nwg-shell tools..."
sudo apt install -y \
    nwg-displays \
    nwg-look || print_warning "nwg tools not available, may need manual install"

# Image tools
print_info "Installing image tools..."
sudo apt install -y imagemagick

# XDG portal for screen sharing
print_info "Configuring XDG portals..."
sudo apt install -y \
    xdg-desktop-portal \
    xdg-desktop-portal-gtk

# Create XDG portal config for Hyprland
mkdir -p "$HOME/.config/xdg-desktop-portal"
cat > "$HOME/.config/xdg-desktop-portal/portals.conf" << 'EOF'
[preferred]
default=hyprland;gtk
org.freedesktop.impl.portal.Screenshot=hyprland
org.freedesktop.impl.portal.ScreenCast=hyprland
EOF

print_success "Hyprland + Wayland ecosystem installation complete!"
print_info "Please log out and select Hyprland from your display manager."
