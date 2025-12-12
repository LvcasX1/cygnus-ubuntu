#!/bin/bash
# Cygnus-Ubuntu: ASUS Tools Installation
# Part of Cygnus-Ubuntu Installer
#
# Based on: asus-linux/asus-ubuntu (https://gitlab.com/asus-linux/asus-ubuntu)
# Installs: asusctl, supergfxctl, rogauracore, cirrus audio fix

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

ASUS_UBUNTU_DIR="/tmp/asus-ubuntu"

# Check if running on ASUS hardware
check_asus_hardware() {
    if [[ -d /sys/class/leds/asus::kbd_backlight ]] || \
       lsusb | grep -qi "ASUSTeK" || \
       dmidecode -s system-manufacturer 2>/dev/null | grep -qi "ASUSTeK"; then
        return 0
    fi
    return 1
}

# Install build dependencies
install_build_deps() {
    print_info "Installing build dependencies..."
    sudo apt install -y \
        git \
        curl \
        build-essential \
        cmake \
        pkg-config \
        libclang-dev \
        libudev-dev \
        libinput-dev \
        libseat-dev \
        libgbm-dev \
        libdrm-dev \
        libsystemd-dev \
        libdbus-1-dev \
        libpixman-1-dev \
        libxkbcommon-dev \
        libusb-1.0-0-dev \
        libhidapi-dev \
        libpci-dev \
        docker.io \
        docker-compose
}

# Install Rust if not present
install_rust() {
    if ! command -v cargo &> /dev/null; then
        print_info "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi
}

# Add user to docker group
setup_docker() {
    print_info "Setting up Docker..."
    sudo systemctl enable docker
    sudo systemctl start docker

    if ! groups | grep -q docker; then
        sudo usermod -aG docker "$USER"
        print_warning "Added $USER to docker group. You may need to log out and back in."
    fi
}

# Clone asus-ubuntu repository
clone_asus_ubuntu() {
    print_info "Cloning asus-ubuntu repository..."
    rm -rf "$ASUS_UBUNTU_DIR"
    git clone https://gitlab.com/asus-linux/asus-ubuntu.git "$ASUS_UBUNTU_DIR"
}

# Install asusctl from asus-ubuntu builder or COPR-equivalent
install_asusctl() {
    print_info "Installing asusctl..."

    # Method 1: Try pre-built packages from asus-linux repos
    # Add the ASUS Linux signing key and repo
    if [[ ! -f /etc/apt/sources.list.d/asus-linux.list ]]; then
        print_info "Adding ASUS Linux repository..."

        # Download and add GPG key
        curl -L https://download.opensuse.org/repositories/home:/luke_nukem:/asus/xUbuntu_24.04/Release.key | \
            sudo gpg --dearmor -o /usr/share/keyrings/asus-linux.gpg

        # Add repository
        echo "deb [signed-by=/usr/share/keyrings/asus-linux.gpg] https://download.opensuse.org/repositories/home:/luke_nukem:/asus/xUbuntu_24.04/ /" | \
            sudo tee /etc/apt/sources.list.d/asus-linux.list

        sudo apt update
    fi

    # Try to install from repo
    if apt-cache show asusctl &> /dev/null; then
        sudo apt install -y asusctl
        print_success "asusctl installed from repository"
    else
        # Method 2: Build from source using asus-ubuntu
        print_warning "asusctl not in repos, building from source..."
        build_asusctl_from_source
    fi

    # Enable and start asusd service
    sudo systemctl enable asusd
    sudo systemctl start asusd || print_warning "asusd service failed to start (may need reboot)"
}

# Build asusctl from source
build_asusctl_from_source() {
    install_rust
    clone_asus_ubuntu

    cd "$ASUS_UBUNTU_DIR"

    # Check if Docker builder method exists
    if [[ -f "build.sh" ]]; then
        print_info "Building with Docker builder..."
        ./build.sh
        # Install generated debs
        sudo dpkg -i debs/*.deb || sudo apt install -f -y
    else
        # Manual build
        print_info "Building asusctl manually..."
        git clone https://gitlab.com/asus-linux/asusctl.git /tmp/asusctl
        cd /tmp/asusctl
        make
        sudo make install
        cd -
    fi
}

# Install supergfxctl (GPU switching)
install_supergfxctl() {
    print_info "Installing supergfxctl..."

    if apt-cache show supergfxctl &> /dev/null; then
        sudo apt install -y supergfxctl
        print_success "supergfxctl installed from repository"
    else
        print_warning "supergfxctl not in repos, may need manual installation"
    fi

    # Enable service if installed
    if command -v supergfxctl &> /dev/null; then
        sudo systemctl enable supergfxd
        sudo systemctl start supergfxd || print_warning "supergfxd service failed to start"
    fi
}

# Install rogauracore (keyboard RGB for older ASUS laptops)
install_rogauracore() {
    print_info "Installing rogauracore..."

    # Build from source
    if [[ ! -f /usr/local/bin/rogauracore ]]; then
        print_info "Building rogauracore from source..."

        sudo apt install -y libusb-1.0-0-dev

        git clone https://github.com/wroberts/rogauracore.git /tmp/rogauracore
        cd /tmp/rogauracore

        # Build
        autoreconf -i 2>/dev/null || {
            # Manual build if autoreconf not available
            gcc -o rogauracore rogauracore.c -lusb-1.0
        }

        if [[ -f configure ]]; then
            ./configure
            make
            sudo make install
        elif [[ -f rogauracore ]]; then
            sudo cp rogauracore /usr/local/bin/
        fi

        cd -
        rm -rf /tmp/rogauracore

        print_success "rogauracore installed"
    else
        print_info "rogauracore already installed"
    fi
}

# Apply Cirrus audio fix (CS35L41)
apply_cirrus_fix() {
    print_info "Applying Cirrus audio fix..."

    # This fix is for ASUS laptops with Cirrus CS35L41 speakers
    # The firmware needs to be installed for proper audio

    CIRRUS_FW_DIR="/lib/firmware/cirrus"

    # Check if cirrus firmware directory exists
    if [[ ! -d "$CIRRUS_FW_DIR" ]]; then
        sudo mkdir -p "$CIRRUS_FW_DIR"
    fi

    # Clone the cirrus firmware repo if needed
    if [[ ! -f "$CIRRUS_FW_DIR/cs35l41-dsp1-spk-prot.wmfw" ]]; then
        print_info "Downloading Cirrus CS35L41 firmware..."

        # Clone asus-ubuntu to get the cirrus_fix script
        if [[ ! -d "$ASUS_UBUNTU_DIR" ]]; then
            clone_asus_ubuntu
        fi

        # Check for cirrus_fix.sh script
        if [[ -f "$ASUS_UBUNTU_DIR/cirrus_fix.sh" ]]; then
            print_info "Running cirrus_fix.sh..."
            sudo bash "$ASUS_UBUNTU_DIR/cirrus_fix.sh"
        else
            # Manual firmware setup
            print_info "Setting up Cirrus firmware manually..."

            # The firmware files typically come from the linux-firmware package
            sudo apt install -y linux-firmware

            # Some ASUS laptops need specific firmware from cs35l41-hda project
            if [[ ! -f "$CIRRUS_FW_DIR/cs35l41-dsp1-spk-prot.wmfw" ]]; then
                print_warning "Cirrus firmware may need manual configuration for your specific laptop model."
                print_info "See: https://github.com/CirrusLogic/linux-firmware/tree/main/cirrus"
            fi
        fi
    else
        print_info "Cirrus firmware already installed"
    fi

    print_success "Cirrus audio fix applied (reboot may be required)"
}

# Main installation
main() {
    print_info "ASUS Tools Installation"
    echo ""

    # Check for ASUS hardware
    if ! check_asus_hardware; then
        print_warning "ASUS hardware not detected. Continue anyway? [y/N]"
        read -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Skipping ASUS tools installation."
            exit 0
        fi
    fi

    # Install dependencies
    install_build_deps

    # Install each component
    install_asusctl
    install_supergfxctl
    install_rogauracore
    apply_cirrus_fix

    # Cleanup
    rm -rf "$ASUS_UBUNTU_DIR"

    print_success "ASUS tools installation complete!"
    print_info ""
    print_info "Installed tools:"
    print_info "  - asusctl: System control (fan profiles, keyboard, etc.)"
    print_info "  - supergfxctl: GPU switching (if applicable)"
    print_info "  - rogauracore: Keyboard RGB control"
    print_info ""
    print_info "A reboot is recommended to activate all features."
    print_info ""
    print_info "Quick commands:"
    print_info "  asusctl profile -l          # List power profiles"
    print_info "  asusctl -k high             # Set keyboard brightness"
    print_info "  asusctl aura static -c ff0000  # Set keyboard color (red)"
    print_info "  rogauracore single_static ff0000  # Alternative RGB control"
}

main "$@"
