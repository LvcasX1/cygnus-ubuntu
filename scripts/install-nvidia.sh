#!/bin/bash
# Cygnus-Ubuntu: NVIDIA Driver Installation
# Part of Cygnus-Ubuntu Installer
#
# Installs NVIDIA drivers configured for Wayland/Hyprland

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

# Check for NVIDIA GPU
check_nvidia_gpu() {
    if lspci | grep -i nvidia &> /dev/null; then
        print_success "NVIDIA GPU detected"
        lspci | grep -i nvidia
        return 0
    else
        print_warning "No NVIDIA GPU detected"
        return 1
    fi
}

# Install ubuntu-drivers tool
install_ubuntu_drivers() {
    print_info "Installing ubuntu-drivers..."
    sudo apt install -y ubuntu-drivers-common
}

# Show available drivers
show_available_drivers() {
    print_info "Available NVIDIA drivers:"
    ubuntu-drivers devices
}

# Install recommended driver
install_nvidia_driver() {
    print_info "Installing NVIDIA driver..."

    # Let user choose or auto-install
    print_info "Options:"
    echo "  1) Auto-install recommended driver"
    echo "  2) Install specific version (nvidia-driver-560 recommended for newer GPUs)"
    echo "  3) Install latest (nvidia-driver-570 or newer)"
    read -p "Select option [1-3]: " choice

    case $choice in
        1)
            print_info "Installing recommended driver..."
            sudo ubuntu-drivers install
            ;;
        2)
            print_info "Installing nvidia-driver-560..."
            sudo apt install -y nvidia-driver-560
            ;;
        3)
            print_info "Installing latest driver..."
            # Find latest available
            LATEST=$(apt-cache search nvidia-driver | grep -oP 'nvidia-driver-\d+' | sort -V | tail -1)
            print_info "Latest available: $LATEST"
            sudo apt install -y "$LATEST"
            ;;
        *)
            print_warning "Invalid option, installing recommended..."
            sudo ubuntu-drivers install
            ;;
    esac
}

# Configure for Wayland
configure_wayland() {
    print_info "Configuring NVIDIA for Wayland..."

    # Create modprobe configuration
    MODPROBE_CONF="/etc/modprobe.d/nvidia-wayland.conf"
    sudo tee "$MODPROBE_CONF" > /dev/null << 'EOF'
# Enable DRM kernel mode setting for NVIDIA
options nvidia_drm modeset=1
options nvidia_drm fbdev=1
EOF

    print_success "Created $MODPROBE_CONF"

    # Add nvidia modules to initramfs
    MODULES_CONF="/etc/modules-load.d/nvidia.conf"
    sudo tee "$MODULES_CONF" > /dev/null << 'EOF'
nvidia
nvidia_modeset
nvidia_uvm
nvidia_drm
EOF

    print_success "Created $MODULES_CONF"

    # Update initramfs
    print_info "Updating initramfs..."
    sudo update-initramfs -u

    # Set environment variables for Wayland
    ENV_CONF="/etc/environment.d/nvidia-wayland.conf"
    sudo mkdir -p /etc/environment.d
    sudo tee "$ENV_CONF" > /dev/null << 'EOF'
# NVIDIA Wayland environment variables
GBM_BACKEND=nvidia-drm
__GLX_VENDOR_LIBRARY_NAME=nvidia
LIBVA_DRIVER_NAME=nvidia
WLR_NO_HARDWARE_CURSORS=1
EOF

    print_success "Created $ENV_CONF"
}

# Install VAAPI driver for hardware video acceleration
install_vaapi() {
    print_info "Installing NVIDIA VAAPI driver for hardware video acceleration..."

    # nvidia-vaapi-driver enables hardware video decode in Firefox/Chrome
    if apt-cache show nvidia-vaapi-driver &> /dev/null; then
        sudo apt install -y nvidia-vaapi-driver
        print_success "nvidia-vaapi-driver installed"
    else
        print_warning "nvidia-vaapi-driver not available in repos"
        print_info "You may need to build from source: https://github.com/elFarto/nvidia-vaapi-driver"
    fi

    # Install libva
    sudo apt install -y libva2 libva-drm2 vainfo
}

# Install additional NVIDIA utilities
install_nvidia_utils() {
    print_info "Installing NVIDIA utilities..."
    sudo apt install -y \
        nvidia-settings \
        nvidia-prime \
        nvtop
}

# Configure GDM for Wayland (if using GDM)
configure_gdm_wayland() {
    GDM_CONF="/etc/gdm3/custom.conf"
    if [[ -f "$GDM_CONF" ]]; then
        print_info "Configuring GDM for Wayland..."

        # Enable Wayland in GDM
        if grep -q "WaylandEnable=false" "$GDM_CONF"; then
            sudo sed -i 's/WaylandEnable=false/WaylandEnable=true/' "$GDM_CONF"
            print_success "Enabled Wayland in GDM"
        fi
    fi
}

# Create Hyprland-specific NVIDIA wrapper (optional)
create_hyprland_wrapper() {
    print_info "Creating Hyprland NVIDIA wrapper..."

    WRAPPER_DIR="$HOME/.local/bin"
    mkdir -p "$WRAPPER_DIR"

    cat > "$WRAPPER_DIR/hyprland-nvidia" << 'EOF'
#!/bin/bash
# Hyprland NVIDIA wrapper script
# Sets environment variables for optimal NVIDIA + Wayland experience

export LIBVA_DRIVER_NAME=nvidia
export XDG_SESSION_TYPE=wayland
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export WLR_NO_HARDWARE_CURSORS=1
export XCURSOR_SIZE=24

# Optional: Force software cursors if hardware cursors cause issues
# export WLR_NO_HARDWARE_CURSORS=1

exec Hyprland "$@"
EOF

    chmod +x "$WRAPPER_DIR/hyprland-nvidia"
    print_success "Created $WRAPPER_DIR/hyprland-nvidia"
}

# Main installation
main() {
    print_info "NVIDIA Driver Installation for Wayland/Hyprland"
    echo ""

    # Check for NVIDIA GPU
    if ! check_nvidia_gpu; then
        print_warning "Continue without NVIDIA GPU? [y/N]"
        read -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi

    # Install ubuntu-drivers
    install_ubuntu_drivers

    # Show available drivers
    show_available_drivers

    # Confirm installation
    echo ""
    print_warning "This will install NVIDIA drivers. Continue? [y/N]"
    read -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Skipping NVIDIA driver installation."
        exit 0
    fi

    # Install driver
    install_nvidia_driver

    # Configure for Wayland
    configure_wayland

    # Install VAAPI
    install_vaapi

    # Install utilities
    install_nvidia_utils

    # Configure GDM
    configure_gdm_wayland

    # Create wrapper script
    create_hyprland_wrapper

    print_success "NVIDIA driver installation complete!"
    print_info ""
    print_info "Configuration applied:"
    print_info "  - nvidia_drm.modeset=1 (DRM KMS enabled)"
    print_info "  - Environment variables for Wayland set"
    print_info "  - VAAPI driver for hardware video acceleration"
    print_info ""
    print_warning "A REBOOT IS REQUIRED for changes to take effect!"
    print_info ""
    print_info "After reboot, verify with:"
    print_info "  nvidia-smi              # Check driver is loaded"
    print_info "  cat /sys/module/nvidia_drm/parameters/modeset  # Should be 'Y'"
    print_info "  vainfo                  # Check VAAPI is working"
}

main "$@"
