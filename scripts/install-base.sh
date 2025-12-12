#!/bin/bash
# Cygnus-Ubuntu: Base System Packages Installation
# Part of Cygnus-Ubuntu Installer

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

# Update package lists
print_info "Updating package lists..."
sudo apt update

# Core utilities
print_info "Installing core utilities..."
sudo apt install -y \
    git \
    curl \
    wget \
    unzip \
    jq \
    bc \
    socat \
    acpi

# Development tools
print_info "Installing development tools..."
sudo apt install -y \
    build-essential \
    cmake \
    pkg-config \
    libssl-dev \
    meson \
    ninja-build

# Search and navigation tools
print_info "Installing search and navigation tools..."
sudo apt install -y \
    ripgrep \
    fd-find \
    fzf

# Modern CLI replacements
print_info "Installing modern CLI tools..."
# bat (better cat)
if ! command -v bat &> /dev/null && ! command -v batcat &> /dev/null; then
    sudo apt install -y bat
fi

# eza (better ls) - may need to install from GitHub releases on older Ubuntu
if ! command -v eza &> /dev/null; then
    if apt-cache show eza &> /dev/null; then
        sudo apt install -y eza
    else
        print_warning "eza not available in repos, installing from GitHub..."
        EZA_VERSION=$(curl -s "https://api.github.com/repos/eza-community/eza/releases/latest" | jq -r '.tag_name' | tr -d 'v')
        wget -q "https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/eza_x86_64-unknown-linux-gnu.tar.gz" -O /tmp/eza.tar.gz
        tar -xzf /tmp/eza.tar.gz -C /tmp
        sudo mv /tmp/eza /usr/local/bin/
        rm /tmp/eza.tar.gz
    fi
fi

# zoxide (better cd) - install via script for latest version
if ! command -v zoxide &> /dev/null; then
    print_info "Installing zoxide..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi

# Audio system (PipeWire)
print_info "Installing PipeWire audio system..."
sudo apt install -y \
    pipewire \
    pipewire-alsa \
    pipewire-pulse \
    pipewire-audio \
    wireplumber

# Network management
print_info "Installing network tools..."
sudo apt install -y \
    network-manager \
    network-manager-gnome

# Polkit (for privilege escalation dialogs)
print_info "Installing polkit..."
sudo apt install -y policykit-1-gnome

# Fonts
print_info "Installing fonts..."
sudo apt install -y \
    fonts-jetbrains-mono \
    fonts-noto-color-emoji \
    fonts-font-awesome

# Additional font: JetBrains Mono Nerd Font
print_info "Installing JetBrains Mono Nerd Font..."
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

if [[ ! -f "$FONT_DIR/JetBrainsMonoNerdFont-Regular.ttf" ]]; then
    NF_VERSION=$(curl -s "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" | jq -r '.tag_name')
    wget -q "https://github.com/ryanoasis/nerd-fonts/releases/download/${NF_VERSION}/JetBrainsMono.zip" -O /tmp/JetBrainsMono.zip
    unzip -o /tmp/JetBrainsMono.zip -d "$FONT_DIR"
    rm /tmp/JetBrainsMono.zip
    fc-cache -fv
    print_success "JetBrains Mono Nerd Font installed"
else
    print_info "JetBrains Mono Nerd Font already installed"
fi

# GTK/Qt theming tools
print_info "Installing theming tools..."
sudo apt install -y \
    qt5ct \
    qt6ct \
    kvantum

# Misc utilities used by scripts
print_info "Installing miscellaneous utilities..."
sudo apt install -y \
    imagemagick \
    python3-pip \
    python3-venv

print_success "Base system packages installation complete!"
