#!/bin/bash
# Cygnus-Ubuntu: Claude Code CLI Installation
# Part of Cygnus-Ubuntu Installer
#
# Installs Claude Code CLI from Anthropic

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

# Check Node.js version
check_node() {
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node -v | tr -d 'v' | cut -d. -f1)
        if [[ "$NODE_VERSION" -ge 20 ]]; then
            print_success "Node.js $(node -v) installed (>= v20 required)"
            return 0
        else
            print_warning "Node.js $(node -v) is too old. Need v20+"
            return 1
        fi
    else
        print_warning "Node.js not found"
        return 1
    fi
}

# Install Node.js
install_node() {
    print_info "Installing Node.js..."

    # Method 1: Use mise if available
    if command -v mise &> /dev/null; then
        print_info "Installing Node.js via mise..."
        mise use --global node@lts
        eval "$(mise activate bash)"
        print_success "Node.js installed via mise"
        return 0
    fi

    # Method 2: Use nvm
    if [[ -d "$HOME/.nvm" ]]; then
        print_info "Installing Node.js via nvm..."
        source "$HOME/.nvm/nvm.sh"
        nvm install --lts
        nvm use --lts
        print_success "Node.js installed via nvm"
        return 0
    fi

    # Method 3: Install from NodeSource
    print_info "Installing Node.js via NodeSource..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt install -y nodejs
    print_success "Node.js installed via NodeSource"
}

# Install Claude Code CLI
install_claude_code() {
    print_info "Installing Claude Code CLI..."

    # Install globally via npm
    npm install -g @anthropic-ai/claude-code

    if command -v claude &> /dev/null; then
        print_success "Claude Code CLI installed successfully!"
        claude --version
    else
        print_error "Claude Code CLI installation failed"
        exit 1
    fi
}

# Setup API key (optional)
setup_api_key() {
    print_info ""
    print_info "Claude Code requires an Anthropic API key to function."
    print_info "You can set it up now or later."
    print_info ""
    print_info "Set up API key now? [y/N]"
    read -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Enter your Anthropic API key:"
        read -r API_KEY

        if [[ -n "$API_KEY" ]]; then
            # Add to shell config
            if [[ -f "$HOME/.zshrc" ]]; then
                echo "" >> "$HOME/.zshrc"
                echo "# Anthropic API Key" >> "$HOME/.zshrc"
                echo "export ANTHROPIC_API_KEY=\"$API_KEY\"" >> "$HOME/.zshrc"
                print_success "API key added to ~/.zshrc"
            elif [[ -f "$HOME/.bashrc" ]]; then
                echo "" >> "$HOME/.bashrc"
                echo "# Anthropic API Key" >> "$HOME/.bashrc"
                echo "export ANTHROPIC_API_KEY=\"$API_KEY\"" >> "$HOME/.bashrc"
                print_success "API key added to ~/.bashrc"
            fi

            # Export for current session
            export ANTHROPIC_API_KEY="$API_KEY"
        fi
    else
        print_info ""
        print_info "To set up later, add to your shell config:"
        print_info "  export ANTHROPIC_API_KEY=\"your-api-key\""
        print_info ""
        print_info "Or run: claude auth"
    fi
}

# Main installation
main() {
    print_info "Claude Code CLI Installation"
    echo ""

    # Check/install Node.js
    if ! check_node; then
        install_node

        # Verify installation
        if ! check_node; then
            print_error "Failed to install Node.js"
            exit 1
        fi
    fi

    # Install Claude Code
    install_claude_code

    # Setup API key
    setup_api_key

    print_success "Claude Code CLI installation complete!"
    print_info ""
    print_info "Usage:"
    print_info "  claude            # Start interactive mode"
    print_info "  claude \"prompt\"   # Send a single prompt"
    print_info "  claude auth       # Authenticate with Anthropic"
    print_info ""
    print_info "Documentation: https://docs.anthropic.com/claude-code"
}

main "$@"
