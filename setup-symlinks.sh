#!/bin/bash
# Cygnus-Ubuntu: Dotfiles Symlink Setup
# Part of Cygnus-Ubuntu Installer
#
# Creates symlinks from the repo dotfiles to their expected locations

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_warning() { echo -e "${YELLOW}! $1${NC}"; }
print_info() { echo -e "${BLUE}→ $1${NC}"; }

# Script directory (repo root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"
BACKUP_DIR="$HOME/.config/cygnus-ubuntu-backups/$(date +%Y%m%d_%H%M%S)"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup and remove existing file/directory
backup_existing() {
    local target=$1
    local name=$(basename "$target")

    if [[ -e "$target" ]] && [[ ! -L "$target" ]]; then
        print_warning "Backing up existing $name to $BACKUP_DIR/"
        mv "$target" "$BACKUP_DIR/"
    elif [[ -L "$target" ]]; then
        # Remove existing symlink
        rm "$target"
    fi
}

# Create symlink
create_symlink() {
    local source=$1
    local target=$2
    local name=$(basename "$target")

    if [[ ! -e "$source" ]]; then
        print_warning "Source not found: $source"
        return 1
    fi

    # Ensure parent directory exists
    mkdir -p "$(dirname "$target")"

    # Backup existing
    backup_existing "$target"

    # Create symlink
    ln -sf "$source" "$target"
    print_success "Linked $name → $source"
}

echo ""
echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}${BOLD}  Cygnus-Ubuntu Dotfiles Symlink Setup${NC}"
echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Check if dotfiles directory exists
if [[ ! -d "$DOTFILES_DIR" ]]; then
    print_error "Dotfiles directory not found: $DOTFILES_DIR"
    print_info "Please run the installer first to set up the dotfiles directory."
    exit 1
fi

print_info "Source: $DOTFILES_DIR"
print_info "Backups will be saved to: $BACKUP_DIR"
echo ""

# Hyprland configuration
if [[ -d "$DOTFILES_DIR/hypr" ]]; then
    print_info "Setting up Hyprland configuration..."
    create_symlink "$DOTFILES_DIR/hypr" "$HOME/.config/hypr"
fi

# Waybar configuration
if [[ -d "$DOTFILES_DIR/waybar" ]]; then
    print_info "Setting up Waybar configuration..."
    create_symlink "$DOTFILES_DIR/waybar" "$HOME/.config/waybar"
fi

# Rofi configuration
if [[ -d "$DOTFILES_DIR/rofi" ]]; then
    print_info "Setting up Rofi configuration..."
    create_symlink "$DOTFILES_DIR/rofi" "$HOME/.config/rofi"
fi

# Neovim configuration
if [[ -d "$DOTFILES_DIR/nvim" ]]; then
    print_info "Setting up Neovim configuration..."
    create_symlink "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
fi

# SwayNC configuration
if [[ -d "$DOTFILES_DIR/swaync" ]]; then
    print_info "Setting up SwayNC configuration..."
    create_symlink "$DOTFILES_DIR/swaync" "$HOME/.config/swaync"
fi

# WezTerm configuration
if [[ -d "$DOTFILES_DIR/wezterm" ]]; then
    print_info "Setting up WezTerm configuration..."
    create_symlink "$DOTFILES_DIR/wezterm" "$HOME/.config/wezterm"
fi

# Kitty configuration
if [[ -d "$DOTFILES_DIR/kitty" ]]; then
    print_info "Setting up Kitty configuration..."
    create_symlink "$DOTFILES_DIR/kitty" "$HOME/.config/kitty"
fi

# Zsh configuration
if [[ -f "$DOTFILES_DIR/zshrc" ]]; then
    print_info "Setting up Zsh configuration..."
    create_symlink "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
fi

# Starship configuration
if [[ -f "$DOTFILES_DIR/starship.toml" ]]; then
    print_info "Setting up Starship configuration..."
    create_symlink "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"
fi

# Cava configuration
if [[ -d "$DOTFILES_DIR/cava" ]]; then
    print_info "Setting up Cava configuration..."
    create_symlink "$DOTFILES_DIR/cava" "$HOME/.config/cava"
fi

# Btop configuration
if [[ -d "$DOTFILES_DIR/btop" ]]; then
    print_info "Setting up Btop configuration..."
    create_symlink "$DOTFILES_DIR/btop" "$HOME/.config/btop"
fi

# Fastfetch configuration
if [[ -d "$DOTFILES_DIR/fastfetch" ]]; then
    print_info "Setting up Fastfetch configuration..."
    create_symlink "$DOTFILES_DIR/fastfetch" "$HOME/.config/fastfetch"
fi

# GTK themes and settings
if [[ -d "$DOTFILES_DIR/gtk-3.0" ]]; then
    print_info "Setting up GTK-3.0 configuration..."
    create_symlink "$DOTFILES_DIR/gtk-3.0" "$HOME/.config/gtk-3.0"
fi

if [[ -d "$DOTFILES_DIR/gtk-4.0" ]]; then
    print_info "Setting up GTK-4.0 configuration..."
    create_symlink "$DOTFILES_DIR/gtk-4.0" "$HOME/.config/gtk-4.0"
fi

# Qt5ct configuration
if [[ -d "$DOTFILES_DIR/qt5ct" ]]; then
    print_info "Setting up Qt5ct configuration..."
    create_symlink "$DOTFILES_DIR/qt5ct" "$HOME/.config/qt5ct"
fi

# Kvantum configuration
if [[ -d "$DOTFILES_DIR/Kvantum" ]]; then
    print_info "Setting up Kvantum configuration..."
    create_symlink "$DOTFILES_DIR/Kvantum" "$HOME/.config/Kvantum"
fi

echo ""
print_success "Symlink setup complete!"
echo ""

# Check if backup directory has files
if [[ "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]]; then
    print_info "Backed up files are in: $BACKUP_DIR"
else
    # Remove empty backup directory
    rmdir "$BACKUP_DIR" 2>/dev/null || true
fi

print_info ""
print_info "To reload Hyprland: hyprctl reload"
print_info "To restart Waybar: pkill waybar && waybar &"
