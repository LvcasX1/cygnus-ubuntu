#!/bin/bash
# Cygnus-Ubuntu Installer v1.0
# A modular installation script for Hyprland on Ubuntu 24.04
#
# Based on:
# - JaKooLit/Ubuntu-Hyprland (https://github.com/JaKooLit/Ubuntu-Hyprland)
# - asus-linux/asus-ubuntu (https://gitlab.com/asus-linux/asus-ubuntu)

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"

# Print colored output
print_color() {
    local color=$1
    shift
    echo -e "${color}$*${NC}"
}

print_header() {
    echo ""
    print_color "$CYAN" "═══════════════════════════════════════════════════════════"
    print_color "$BOLD$CYAN" "  $1"
    print_color "$CYAN" "═══════════════════════════════════════════════════════════"
    echo ""
}

print_success() {
    print_color "$GREEN" "✓ $1"
}

print_error() {
    print_color "$RED" "✗ $1"
}

print_warning() {
    print_color "$YELLOW" "! $1"
}

print_info() {
    print_color "$BLUE" "→ $1"
}

# Check if running as root
check_not_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should NOT be run as root."
        print_info "Run without sudo: ./install.sh"
        exit 1
    fi
}

# Check Ubuntu version
check_ubuntu() {
    if [[ ! -f /etc/os-release ]]; then
        print_error "Cannot detect OS. This script is for Ubuntu 24.04."
        exit 1
    fi

    source /etc/os-release
    if [[ "$ID" != "ubuntu" ]]; then
        print_warning "This script is designed for Ubuntu. Detected: $ID"
        read -p "Continue anyway? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Execute a script module
execute_script() {
    local script_name=$1
    local script_path="$SCRIPTS_DIR/$script_name"

    if [[ -f "$script_path" ]]; then
        print_info "Running $script_name..."
        chmod +x "$script_path"
        bash "$script_path"
        print_success "$script_name completed!"
    else
        print_error "Script not found: $script_path"
        return 1
    fi
}

# Show the main menu
show_menu() {
    clear
    echo ""
    print_color "$CYAN" "╔══════════════════════════════════════════════════════════╗"
    print_color "$CYAN" "║                                                          ║"
    print_color "$BOLD$CYAN" "║          Cygnus-Ubuntu Installer v1.0                   ║"
    print_color "$CYAN" "║          Hyprland Desktop for Ubuntu 24.04               ║"
    print_color "$CYAN" "║                                                          ║"
    print_color "$CYAN" "╠══════════════════════════════════════════════════════════╣"
    print_color "$CYAN" "║                                                          ║"
    print_color "$GREEN" "║  1)  Install Everything (Full Setup)                     ║"
    print_color "$CYAN" "║                                                          ║"
    print_color "$CYAN" "║  Individual Components:                                  ║"
    print_color "$CYAN" "║  2)  Base System Packages                                ║"
    print_color "$CYAN" "║  3)  Hyprland + Wayland Ecosystem                        ║"
    print_color "$CYAN" "║  4)  Shell (Zsh + Oh-my-zsh + plugins)                   ║"
    print_color "$CYAN" "║  5)  Neovim + LazyVim                                    ║"
    print_color "$CYAN" "║  6)  ASUS Tools (asusctl, rogauracore)                   ║"
    print_color "$CYAN" "║  7)  NVIDIA Drivers                                      ║"
    print_color "$CYAN" "║  8)  Applications                                        ║"
    print_color "$CYAN" "║  9)  Claude Code CLI                                     ║"
    print_color "$CYAN" "║                                                          ║"
    print_color "$YELLOW" "║  S)  Setup Symlinks Only                                 ║"
    print_color "$YELLOW" "║  W)  Setup Wallpapers                                    ║"
    print_color "$CYAN" "║                                                          ║"
    print_color "$RED" "║  Q)  Quit                                                ║"
    print_color "$CYAN" "║                                                          ║"
    print_color "$CYAN" "╚══════════════════════════════════════════════════════════╝"
    echo ""
}

# Install everything
install_all() {
    print_header "Installing Everything"

    print_warning "This will install all components. Continue? [y/N]"
    read -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return
    fi

    execute_script "install-base.sh"
    execute_script "install-hyprland.sh"
    execute_script "install-shell.sh"
    execute_script "install-nvim.sh"
    execute_script "install-nvidia.sh"
    execute_script "install-asus.sh"
    execute_script "install-apps.sh"
    execute_script "install-claude.sh"

    # Setup symlinks and wallpapers
    bash "$SCRIPT_DIR/setup-symlinks.sh"
    setup_wallpapers

    print_header "Installation Complete!"
    print_success "All components have been installed."
    print_info "Please log out and log back in, or reboot your system."
    print_info "Then select Hyprland from your display manager."
}

# Setup wallpapers
setup_wallpapers() {
    print_header "Setting up Wallpapers"

    local wallpaper_src="$SCRIPT_DIR/wallpapers"
    local wallpaper_dest="$HOME/Pictures/wallpapers"

    mkdir -p "$wallpaper_dest"

    if [[ -d "$wallpaper_src" ]]; then
        cp -n "$wallpaper_src"/*.png "$wallpaper_dest/" 2>/dev/null || true
        print_success "Wallpapers copied to $wallpaper_dest"

        # Set default wallpaper
        local default_wallpaper="$wallpaper_dest/tokyonight_original.png"
        if [[ -f "$default_wallpaper" ]]; then
            mkdir -p "$HOME/.config/cygnus-ubuntu/current"
            cp "$default_wallpaper" "$HOME/.config/cygnus-ubuntu/current/background"
            print_success "Default wallpaper set to tokyonight_original.png"
        fi
    else
        print_warning "Wallpapers directory not found: $wallpaper_src"
    fi
}

# Main function
main() {
    check_not_root
    check_ubuntu

    while true; do
        show_menu
        read -p "Select an option: " choice

        case $choice in
            1)
                install_all
                read -p "Press Enter to continue..."
                ;;
            2)
                execute_script "install-base.sh"
                read -p "Press Enter to continue..."
                ;;
            3)
                execute_script "install-hyprland.sh"
                read -p "Press Enter to continue..."
                ;;
            4)
                execute_script "install-shell.sh"
                read -p "Press Enter to continue..."
                ;;
            5)
                execute_script "install-nvim.sh"
                read -p "Press Enter to continue..."
                ;;
            6)
                execute_script "install-asus.sh"
                read -p "Press Enter to continue..."
                ;;
            7)
                execute_script "install-nvidia.sh"
                read -p "Press Enter to continue..."
                ;;
            8)
                execute_script "install-apps.sh"
                read -p "Press Enter to continue..."
                ;;
            9)
                execute_script "install-claude.sh"
                read -p "Press Enter to continue..."
                ;;
            [Ss])
                bash "$SCRIPT_DIR/setup-symlinks.sh"
                read -p "Press Enter to continue..."
                ;;
            [Ww])
                setup_wallpapers
                read -p "Press Enter to continue..."
                ;;
            [Qq])
                print_info "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid option: $choice"
                sleep 1
                ;;
        esac
    done
}

# Run main
main "$@"
