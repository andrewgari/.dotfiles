#!/bin/bash

set -e  # Exit on error

# Detect package manager
detect_package_manager() {
    if command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v apt &> /dev/null; then
        echo "apt"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    else
        echo "Unsupported package manager" >&2
        exit 1
    fi
}

PACKAGE_MANAGER=$(detect_package_manager)

# Common applications to install
APPS=(
    "flatpak"
    "git"
    "neovim"
    "fzf"
    "htop"
    "obs-studio"
    "steam"
    "lutris"
    "kitty"
    "wine"
    "code"  		 # VSCode
    "jetbrains-toolbox"  # JetBrains IDE Manager
    "starship"
    "zsh"
    "zsh-autosuggestions"
    "zsh-syntax-highlighting"
    "docker"
    "docker-compose"
    "podman"
    "protonup-qt"
    "tailscale"
    "android-tools"  	# ADB & Fastboot
    "scrcpy"  		# Android screen mirroring
    "gh"  		# GitHub CLI
    "btrfs-progs"  	# Btrfs utilities
    "rsync"  		# File suynchronization
    "tmux"  		# Terminal multiplexer
    "tldr"  		# Simplified man pages
    "jq"  		# JSON processor
    "yq"  		# YAML processor
    "tree"  		# Directory listing
    "bat"  		# Better cat
    "exa"  		# Better ls
    "ripgrep"  		# Fastergrep
    "fd"  		# Faster find
)

install_dnf() {
    echo "Setting up Fedora..."
    sudo dnf update -y
    
    # Enable RPM Fusion for extra packages
    sudo dnf install -y dnf-plugins-core
    sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    
    # Install apps
    sudo dnf install -y "${APPS[@]}"
    
    # Enable Flatpak
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
}

install_apt() {
    echo "Setting up Debian/Ubuntu..."
    sudo apt update && sudo apt upgrade -y
    
    # Install common dependencies
    sudo apt install -y software-properties-common curl
    
    # Install VSCode repository
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
    sudo apt update
    
    # Install apps
    sudo apt install -y "${APPS[@]}"
    
    # Enable Flatpak
    sudo apt install -y flatpak
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
}

install_pacman() {
    echo "Setting up Arch/Manjaro..."
    sudo pacman -Syu --noconfirm
    
    # Install base apps
    sudo pacman -S --noconfirm "${APPS[@]}"
    
    # Enable Flatpak
    sudo pacman -S --noconfirm flatpak
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    
    # Install and enable AUR helper (yay)
    if ! command -v yay &> /dev/null; then
        echo "Installing yay for AUR support..."
        sudo pacman -S --needed --noconfirm base-devel git
        git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
        cd /tmp/yay-bin && makepkg -si --noconfirm && cd -
        rm -rf /tmp/yay-bin
    fi
}

# Execute the appropriate function
case "$PACKAGE_MANAGER" in
    dnf) install_dnf ;;
    apt) install_apt ;;
    pacman) install_pacman ;;
    *) echo "Unsupported package manager: $PACKAGE_MANAGER" ; exit 1 ;;
esac

# Final message
echo "System bootstrap completed! Reboot recommended."

