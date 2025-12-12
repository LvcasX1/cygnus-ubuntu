# Cygnus-Ubuntu

![Cygnus-Ubuntu Screenshot](screenshot.jpg)

A curated Hyprland desktop environment for Ubuntu 24.04, combining the best configurations and scripts from multiple sources into a cohesive, opinionated setup.

![Hyprland](https://img.shields.io/badge/Hyprland-Wayland-blue)
![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## Overview

Cygnus-Ubuntu is a personal dotfiles collection that merges configurations from several excellent Hyprland/Linux customization projects. It's designed for a fast, keyboard-driven workflow with a cohesive Tokyo Night-inspired aesthetic.

## Sources & Credits

This project is built upon the work of these amazing projects:

| Project | Author | Description |
|---------|--------|-------------|
| [Ubuntu-Hyprland](https://github.com/JaKooLit/Ubuntu-Hyprland) | JaKooLit | Hyprland installation scripts and dotfiles for Ubuntu |
| [Omakub](https://github.com/basecamp/omakub) | Basecamp (DHH) | Opinionated Ubuntu setup for web developers |
| [Omarchy](https://github.com/basecamp/omarchy) | Basecamp (DHH) | Arch Linux variant of Omakub with Hyprland |
| [asus-linux](https://gitlab.com/asus-linux) | Luke Jones | ASUS laptop Linux support (asusctl, supergfxctl) |

## What's Included

### Window Manager & Desktop
- **Hyprland** - Tiling Wayland compositor
- **Waybar** - Customizable status bar
- **Rofi** - Application launcher and menus
- **SwayNC** - Notification center
- **Hyprlock** - Screen locker
- **Hypridle** - Idle daemon
- **swww** - Wallpaper daemon

### Terminal & Shell
- **WezTerm** - GPU-accelerated terminal
- **Kitty** - Alternative terminal
- **Zsh** - Shell with Oh-My-Zsh
- **Starship** - Cross-shell prompt

### Development
- **Neovim** - With LazyVim configuration
- **lazygit** - Terminal UI for git
- **mise** - Polyglot runtime manager

### Theming
- **Flat-Remix GTK** - GTK theme (Blue Dark)
- **Flat-Remix Icons** - Icon theme
- **Bibata Cursors** - Modern cursor theme
- **Kvantum** - Qt theme engine
- **qt5ct/qt6ct** - Qt configuration
- **Wallust** - Colorscheme generation

### Utilities
- **btop** - System monitor
- **cava** - Audio visualizer
- **fastfetch** - System info display
- **swappy** - Screenshot annotation

### ASUS Laptop Support
- **asusctl** - ASUS laptop control
- **supergfxctl** - GPU switching
- **rogauracore** - Keyboard RGB control

## Installation

### Prerequisites

- Ubuntu 24.04 (Noble Numbat) fresh install recommended
- Internet connection
- sudo privileges

### Quick Install

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/cygnus-ubuntu.git ~/.config/cygnus-ubuntu

# Run the installer
cd ~/.config/cygnus-ubuntu
./install.sh
```

### Installation Options

The installer provides a menu with the following options:

| Option | Description |
|--------|-------------|
| **1** | Install Everything (Full Setup) |
| **2** | Base System Packages |
| **3** | Hyprland + Wayland Ecosystem |
| **4** | Shell (Zsh + Oh-my-zsh + plugins) |
| **5** | Neovim + LazyVim |
| **6** | ASUS Tools (asusctl, rogauracore) |
| **7** | NVIDIA Drivers |
| **8** | Applications |
| **9** | Claude Code CLI |
| **T** | GTK/Icon/Cursor Themes |
| **S** | Setup Symlinks Only |
| **W** | Setup Wallpapers |
| **D** | Restore dconf Settings |

### Symlinks Only

If you already have dependencies installed and just want the dotfiles:

```bash
./setup-symlinks.sh
```

This will:
1. Backup existing configs to `~/.config/cygnus-ubuntu-backups/`
2. Create symlinks from the dotfiles to their expected locations

## Directory Structure

```
cygnus-ubuntu/
├── dotfiles/           # Configuration files
│   ├── btop/           # System monitor config
│   ├── cava/           # Audio visualizer config
│   ├── fastfetch/      # System info config
│   ├── dconf/          # GNOME/GTK settings backup
│   ├── gtk-3.0/        # GTK3 settings
│   ├── hypr/           # Hyprland configuration
│   │   ├── configs/    # Modular config files
│   │   ├── scripts/    # Hyprland scripts
│   │   ├── UserConfigs/# User customizations
│   │   └── UserScripts/# User scripts
│   ├── kitty/          # Kitty terminal config
│   ├── Kvantum/        # Qt theme engine
│   ├── nvim/           # Neovim/LazyVim config
│   ├── qt5ct/          # Qt5 configuration
│   ├── rofi/           # Launcher themes
│   ├── swaync/         # Notification center
│   ├── wallust/        # Colorscheme generator
│   ├── waybar/         # Status bar config
│   ├── wezterm/        # Terminal config
│   └── zshrc           # Shell configuration
├── scripts/            # Installation scripts
│   ├── install-apps.sh
│   ├── install-asus.sh
│   ├── install-base.sh
│   ├── install-claude.sh
│   ├── install-hyprland.sh
│   ├── install-nvidia.sh
│   ├── install-nvim.sh
│   ├── install-shell.sh
│   ├── install-themes.sh
│   └── restore-dconf.sh
├── test/               # Testing tools
│   ├── Dockerfile
│   └── docker-test.sh
├── wallpapers/         # Default wallpapers
├── current/            # Current state (wallpaper, etc.)
├── install.sh          # Main installer
├── setup-symlinks.sh   # Symlink setup script
└── README.md           # This file
```

## Keybindings

Default modifier key: `SUPER` (Windows key)

| Keybinding | Action |
|------------|--------|
| `SUPER + Return` | Open terminal |
| `SUPER + D` | Application launcher |
| `SUPER + Q` | Close window |
| `SUPER + M` | Exit Hyprland |
| `SUPER + V` | Toggle floating |
| `SUPER + F` | Toggle fullscreen |
| `SUPER + 1-9` | Switch workspace |
| `SUPER + SHIFT + 1-9` | Move window to workspace |
| `SUPER + Arrow keys` | Move focus |
| `SUPER + SHIFT + Arrow` | Move window |

See `~/.config/hypr/configs/Keybinds.conf` for the complete list.

## Customization

### User Configurations

Personal customizations should go in:
- `~/.config/hypr/UserConfigs/` - Hyprland user configs
- `~/.config/hypr/UserScripts/` - Custom scripts

These directories are preserved during updates.

### Wallpapers

Place wallpapers in `~/Pictures/wallpapers/`. Use the wallpaper selector:
```bash
# SUPER + W (default keybinding)
```

### Theme

The default theme is Tokyo Night. Colors are managed through:
- Kvantum for Qt applications
- GTK themes for GTK applications
- Wallust for dynamic colorscheme generation

## Troubleshooting

### Hyprland won't start
```bash
# Check for errors
Hyprland -c ~/.config/hypr/hyprland.conf
```

### Waybar not showing
```bash
# Restart waybar
pkill waybar && waybar &
```

### Reset to defaults
```bash
# Re-run symlink setup (backups are created automatically)
./setup-symlinks.sh
```

## Contributing

This is a personal configuration, but feel free to fork and adapt it to your needs.

## License

MIT License - See individual project licenses for components from other sources.

## Acknowledgments

Special thanks to:
- **JaKooLit** for the incredible Ubuntu-Hyprland scripts and dotfiles
- **DHH and Basecamp** for Omakub and Omarchy inspiration
- **Luke Jones** for asus-linux tools
- The **Hyprland** community for the amazing compositor
- All the developers of the tools and applications included in this setup
