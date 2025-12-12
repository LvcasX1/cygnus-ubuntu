#!/bin/bash
# Cygnus-Ubuntu: Docker Test Runner
# Tests the installation in an isolated Ubuntu 24.04 container

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
IMAGE_NAME="cygnus-ubuntu-test"
CONTAINER_NAME="cygnus-test"

print_header() {
    echo ""
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}${BOLD}  $1${NC}"
    echo -e "${CYAN}${BOLD}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_info() { echo -e "${BLUE}→ $1${NC}"; }

# Check Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        print_info "Install with: sudo apt install docker.io"
        print_info "Then add user to docker group: sudo usermod -aG docker \$USER"
        exit 1
    fi

    if ! docker info &> /dev/null; then
        print_error "Docker daemon is not running or you don't have permissions"
        print_info "Try: sudo systemctl start docker"
        print_info "Or: sudo usermod -aG docker \$USER (then log out/in)"
        exit 1
    fi

    print_success "Docker is available"
}

# Build the test image
build_image() {
    print_header "Building Test Image"

    cd "$REPO_DIR"
    docker build -t "$IMAGE_NAME" -f test/Dockerfile .

    print_success "Image built: $IMAGE_NAME"
}

# Run interactive test
run_interactive() {
    print_header "Starting Interactive Test Container"

    print_info "You will be dropped into an Ubuntu 24.04 shell"
    print_info "Cygnus-ubuntu is at: ~/.config/cygnus-ubuntu/"
    print_info ""
    print_info "Test commands:"
    print_info "  cd ~/.config/cygnus-ubuntu && ./install.sh"
    print_info "  ./setup-symlinks.sh"
    print_info "  ./validate.sh"
    print_info ""
    print_info "Type 'exit' to leave the container"
    echo ""

    docker run -it --rm \
        --name "$CONTAINER_NAME" \
        --hostname cygnus-test \
        "$IMAGE_NAME" \
        /bin/bash
}

# Run automated tests
run_automated() {
    print_header "Running Automated Tests"

    # Test 1: Check all scripts are executable
    print_info "Test 1: Checking script permissions..."
    docker run --rm "$IMAGE_NAME" bash -c '
        cd ~/.config/cygnus-ubuntu
        errors=0
        for script in install.sh setup-symlinks.sh validate.sh; do
            if [[ -x "$script" ]]; then
                echo "  ✓ $script is executable"
            else
                echo "  ✗ $script is NOT executable"
                errors=$((errors + 1))
            fi
        done
        exit $errors
    ' && print_success "All main scripts are executable" || print_error "Some scripts missing execute permission"

    # Test 2: Check all installation scripts exist
    print_info "Test 2: Checking installation scripts..."
    docker run --rm "$IMAGE_NAME" bash -c '
        cd ~/.config/cygnus-ubuntu/scripts
        expected="install-apps.sh install-asus.sh install-base.sh install-claude.sh install-hyprland.sh install-nvidia.sh install-nvim.sh install-shell.sh"
        errors=0
        for script in $expected; do
            if [[ -f "$script" ]]; then
                echo "  ✓ $script exists"
            else
                echo "  ✗ $script is MISSING"
                errors=$((errors + 1))
            fi
        done
        exit $errors
    ' && print_success "All installation scripts present" || print_error "Some installation scripts missing"

    # Test 3: Check dotfiles structure
    print_info "Test 3: Checking dotfiles structure..."
    docker run --rm "$IMAGE_NAME" bash -c '
        cd ~/.config/cygnus-ubuntu/dotfiles
        expected="hypr rofi waybar nvim swaync wezterm kitty btop cava fastfetch Kvantum qt5ct zshrc"
        errors=0
        for item in $expected; do
            if [[ -e "$item" ]]; then
                echo "  ✓ $item exists"
            else
                echo "  ✗ $item is MISSING"
                errors=$((errors + 1))
            fi
        done
        exit $errors
    ' && print_success "Dotfiles structure valid" || print_error "Some dotfiles missing"

    # Test 4: Test symlink setup (dry run simulation)
    print_info "Test 4: Testing symlink setup..."
    docker run --rm "$IMAGE_NAME" bash -c '
        cd ~/.config/cygnus-ubuntu
        # Run symlink setup
        ./setup-symlinks.sh

        # Verify symlinks were created
        errors=0
        links="$HOME/.config/hypr $HOME/.config/rofi $HOME/.config/nvim $HOME/.zshrc"
        for link in $links; do
            if [[ -L "$link" ]]; then
                echo "  ✓ $link is a symlink"
            else
                echo "  ✗ $link is NOT a symlink"
                errors=$((errors + 1))
            fi
        done
        exit $errors
    ' && print_success "Symlink setup works correctly" || print_error "Symlink setup failed"

    # Test 5: Validate configs match
    print_info "Test 5: Post-symlink validation..."
    docker run --rm "$IMAGE_NAME" bash -c '
        cd ~/.config/cygnus-ubuntu
        # After symlinks, dotfiles and system should be identical (they point to same place)
        ./validate.sh
    ' && print_success "Validation passed" || print_error "Validation found issues"

    print_header "Test Summary"
}

# Cleanup
cleanup() {
    print_header "Cleaning Up"

    docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
    print_success "Container removed"

    read -p "Remove test image? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker rmi "$IMAGE_NAME" 2>/dev/null || true
        print_success "Image removed"
    fi
}

# Show menu
show_menu() {
    echo ""
    echo -e "${CYAN}${BOLD}Cygnus-Ubuntu Docker Test Suite${NC}"
    echo ""
    echo "  1) Build test image"
    echo "  2) Run interactive test (shell into container)"
    echo "  3) Run automated tests"
    echo "  4) Full test (build + automated)"
    echo "  5) Cleanup (remove container/image)"
    echo "  q) Quit"
    echo ""
}

# Main
main() {
    check_docker

    while true; do
        show_menu
        read -p "Select option: " choice

        case $choice in
            1) build_image ;;
            2) build_image; run_interactive ;;
            3) run_automated ;;
            4) build_image; run_automated ;;
            5) cleanup ;;
            q|Q) exit 0 ;;
            *) print_error "Invalid option" ;;
        esac

        echo ""
        read -p "Press Enter to continue..."
    done
}

main "$@"
