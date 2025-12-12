#!/bin/bash
# Cygnus-Ubuntu: Neovim + LazyVim Installation
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

# Install dependencies
print_info "Installing Neovim dependencies..."
sudo apt install -y \
    ripgrep \
    fd-find \
    python3-pip \
    python3-venv \
    python3-neovim \
    xclip \
    wl-clipboard

# Install Node.js (required for many LSPs)
if ! command -v node &> /dev/null; then
    print_info "Installing Node.js via mise..."
    if command -v mise &> /dev/null; then
        mise use --global node@lts
    else
        # Fallback: install via NodeSource
        print_info "Installing Node.js via NodeSource..."
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        sudo apt install -y nodejs
    fi
fi

# Install Neovim (latest stable)
print_info "Installing Neovim..."

# Check if we can get a recent version from apt
NVIM_APT_VERSION=$(apt-cache policy neovim 2>/dev/null | grep Candidate | awk '{print $2}' | cut -d. -f1)

if [[ "$NVIM_APT_VERSION" -ge 9 ]] 2>/dev/null; then
    # apt has a recent enough version
    sudo apt install -y neovim
else
    # Install from GitHub releases (AppImage)
    print_info "Installing Neovim from GitHub releases (apt version too old)..."
    NVIM_VERSION=$(curl -s "https://api.github.com/repos/neovim/neovim/releases/latest" | jq -r '.tag_name')

    wget -q "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux64.tar.gz" -O /tmp/nvim-linux64.tar.gz

    # Extract to /opt
    sudo rm -rf /opt/nvim-linux64
    sudo tar -xzf /tmp/nvim-linux64.tar.gz -C /opt
    rm /tmp/nvim-linux64.tar.gz

    # Create symlink
    sudo ln -sf /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim

    print_success "Neovim $NVIM_VERSION installed to /opt/nvim-linux64"
fi

# Verify installation
if command -v nvim &> /dev/null; then
    INSTALLED_VERSION=$(nvim --version | head -1)
    print_success "Neovim installed: $INSTALLED_VERSION"
else
    print_error "Neovim installation failed!"
    exit 1
fi

# Install tree-sitter CLI (for treesitter parsers)
if ! command -v tree-sitter &> /dev/null; then
    print_info "Installing tree-sitter CLI..."
    if command -v cargo &> /dev/null; then
        cargo install tree-sitter-cli
    elif command -v npm &> /dev/null; then
        npm install -g tree-sitter-cli
    fi
fi

# Install language servers commonly used
print_info "Installing common language servers..."

# Python
pip3 install --user pyright || print_warning "pyright installation failed"

# Lua
if ! command -v lua-language-server &> /dev/null; then
    print_info "Installing lua-language-server..."
    LLS_VERSION=$(curl -s "https://api.github.com/repos/LuaLS/lua-language-server/releases/latest" | jq -r '.tag_name')
    wget -q "https://github.com/LuaLS/lua-language-server/releases/download/${LLS_VERSION}/lua-language-server-${LLS_VERSION}-linux-x64.tar.gz" -O /tmp/lua-ls.tar.gz
    mkdir -p "$HOME/.local/share/lua-language-server"
    tar -xzf /tmp/lua-ls.tar.gz -C "$HOME/.local/share/lua-language-server"
    rm /tmp/lua-ls.tar.gz

    # Create wrapper script
    mkdir -p "$HOME/.local/bin"
    cat > "$HOME/.local/bin/lua-language-server" << 'EOF'
#!/bin/bash
exec "$HOME/.local/share/lua-language-server/bin/lua-language-server" "$@"
EOF
    chmod +x "$HOME/.local/bin/lua-language-server"
fi

# TypeScript/JavaScript (via npm)
if command -v npm &> /dev/null; then
    npm install -g typescript typescript-language-server || print_warning "typescript-language-server installation failed"
fi

print_success "Neovim installation complete!"
print_info ""
print_info "After symlinking your nvim config, run nvim to trigger LazyVim plugin installation."
print_info "First launch may take a few minutes while plugins download."
