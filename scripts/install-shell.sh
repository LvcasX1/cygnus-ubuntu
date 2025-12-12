#!/bin/bash
# Cygnus-Ubuntu: Shell Setup (Zsh + Oh-my-zsh + plugins)
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

# Install Zsh
print_info "Installing Zsh..."
sudo apt install -y zsh

# Install Oh-my-zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    print_info "Installing Oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "Oh-my-zsh installed"
else
    print_info "Oh-my-zsh already installed"
fi

# Oh-my-zsh custom plugins directory
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# Install zsh-syntax-highlighting
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    print_info "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# Install zsh-autosuggestions
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    print_info "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# Install zsh-completions
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]]; then
    print_info "Installing zsh-completions..."
    git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
fi

# Install mise (version manager for Node, Python, etc.)
if ! command -v mise &> /dev/null; then
    print_info "Installing mise (version manager)..."
    curl https://mise.run | sh

    # Add mise to PATH for this session
    export PATH="$HOME/.local/bin:$PATH"

    print_success "mise installed"
else
    print_info "mise already installed"
fi

# Install zoxide (already may be installed in base)
if ! command -v zoxide &> /dev/null; then
    print_info "Installing zoxide..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi

# Install fzf (already may be installed in base)
if ! command -v fzf &> /dev/null; then
    print_info "Installing fzf..."
    sudo apt install -y fzf
fi

# Starship prompt (optional but nice)
if ! command -v starship &> /dev/null; then
    print_info "Installing Starship prompt..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# Set Zsh as default shell
if [[ "$SHELL" != *"zsh"* ]]; then
    print_info "Setting Zsh as default shell..."
    chsh -s "$(which zsh)"
    print_success "Zsh set as default shell (will take effect on next login)"
else
    print_info "Zsh is already the default shell"
fi

print_success "Shell setup complete!"
print_info "Plugins installed: zsh-syntax-highlighting, zsh-autosuggestions, zsh-completions"
print_info "Tools installed: mise, zoxide, fzf, starship"
print_info ""
print_info "After symlinking your .zshrc, restart your terminal or run: source ~/.zshrc"
