#!/bin/bash
# Cygnus-Ubuntu: Restore dconf Settings
# Part of Cygnus-Ubuntu Installer
#
# Restores GNOME/GTK settings from backup

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_info() { echo -e "${BLUE}→ $1${NC}"; }
print_warning() { echo -e "${YELLOW}! $1${NC}"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
DCONF_FILE="$REPO_DIR/dotfiles/dconf/settings.dconf"

if [[ ! -f "$DCONF_FILE" ]]; then
    print_warning "No dconf backup found at: $DCONF_FILE"
    exit 1
fi

print_info "Restoring dconf settings from backup..."
print_warning "This will overwrite current GNOME/GTK settings."
read -p "Continue? [y/N] " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    dconf load / < "$DCONF_FILE"
    print_success "dconf settings restored!"
    print_info "Log out and back in for all changes to take effect."
else
    print_info "Cancelled."
fi
