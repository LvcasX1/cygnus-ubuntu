#!/bin/bash
# Cygnus-Ubuntu: Applications Installation
# Part of Cygnus-Ubuntu Installer
#
# Installs common user applications

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

# Web browsers
install_browsers() {
    print_info "Installing web browsers..."

    # Firefox (prefer apt over snap for better Wayland integration)
    if ! command -v firefox &> /dev/null; then
        # Remove snap version if present and install from apt
        if snap list firefox &> /dev/null 2>&1; then
            print_info "Removing Firefox snap and installing apt version..."
            sudo snap remove firefox 2>/dev/null || true

            # Add Mozilla PPA for latest Firefox
            sudo add-apt-repository -y ppa:mozillateam/ppa

            # Prefer apt over snap
            echo 'Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001' | sudo tee /etc/apt/preferences.d/mozilla-firefox

            sudo apt update
            sudo apt install -y firefox
        else
            sudo apt install -y firefox
        fi
    fi
    print_success "Firefox installed"
}

# Development tools
install_dev_tools() {
    print_info "Installing development tools..."

    # VS Code (optional)
    print_info "Install VS Code? [y/N]"
    read -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if ! command -v code &> /dev/null; then
            wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
            sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
            echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | \
                sudo tee /etc/apt/sources.list.d/vscode.list
            rm /tmp/packages.microsoft.gpg
            sudo apt update
            sudo apt install -y code
            print_success "VS Code installed"
        else
            print_info "VS Code already installed"
        fi
    fi

    # Git GUI tools
    sudo apt install -y gitk git-gui meld
}

# Media applications
install_media() {
    print_info "Installing media applications..."

    sudo apt install -y \
        vlc \
        mpv \
        eog \
        gimp

    # Spotify (via snap - works well)
    print_info "Install Spotify? [y/N]"
    read -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo snap install spotify
        print_success "Spotify installed"
    fi
}

# Communication apps
install_communication() {
    print_info "Installing communication apps..."

    # Discord
    print_info "Install Discord? [y/N]"
    read -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if ! command -v discord &> /dev/null; then
            wget -O /tmp/discord.deb "https://discord.com/api/download?platform=linux&format=deb"
            sudo dpkg -i /tmp/discord.deb || sudo apt install -f -y
            rm /tmp/discord.deb
            print_success "Discord installed"
        else
            print_info "Discord already installed"
        fi
    fi

    # Slack
    print_info "Install Slack? [y/N]"
    read -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo snap install slack
        print_success "Slack installed"
    fi
}

# Productivity apps
install_productivity() {
    print_info "Installing productivity apps..."

    sudo apt install -y \
        gnome-calculator \
        gnome-calendar \
        evince \
        file-roller

    # Obsidian (notes)
    print_info "Install Obsidian? [y/N]"
    read -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if ! command -v obsidian &> /dev/null; then
            # Get latest version
            OBSIDIAN_VERSION=$(curl -s "https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest" | jq -r '.tag_name' | tr -d 'v')
            wget -O /tmp/obsidian.deb "https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VERSION}/obsidian_${OBSIDIAN_VERSION}_amd64.deb"
            sudo dpkg -i /tmp/obsidian.deb || sudo apt install -f -y
            rm /tmp/obsidian.deb
            print_success "Obsidian installed"
        else
            print_info "Obsidian already installed"
        fi
    fi
}

# System utilities
install_system_utils() {
    print_info "Installing system utilities..."

    sudo apt install -y \
        gnome-disk-utility \
        baobab \
        seahorse \
        dconf-editor \
        gnome-tweaks
}

# Flatpak setup (optional)
setup_flatpak() {
    print_info "Setup Flatpak? [y/N]"
    read -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo apt install -y flatpak

        # Add Flathub
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

        print_success "Flatpak configured with Flathub"
        print_info "You can now install apps with: flatpak install flathub <app>"
    fi
}

# Main installation
main() {
    print_info "Applications Installation"
    echo ""

    install_browsers
    install_dev_tools
    install_media
    install_communication
    install_productivity
    install_system_utils
    setup_flatpak

    print_success "Applications installation complete!"
}

main "$@"
