#!/bin/bash

set -e  # Exit on error

# Detect package manager and OS
detect_package_manager() {
    if [[ "$(uname)" == "Darwin" ]]; then
        echo "brew"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v yay &> /dev/null; then
        echo "yay"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    else
        echo "Unsupported package manager" >&2
        exit 1
    fi
}

PACKAGE_MANAGER=$(detect_package_manager)

# Function to install packages and handle missing ones
install_packages() {
    local manager=$1
    shift
    local apps=($@)

    for app in "${apps[@]}"; do
        if ! $manager list --installed "$app" &>/dev/null; then
            echo "Installing $app..."
            if ! $manager install -y "$app" &>/dev/null; then
                echo "Warning: $app could not be installed." >&2
            fi
        else
            echo "$app is already installed, skipping."
        fi
    done
}

# Package lists
APPS_BREW=(
    "git" "neovim" "fzf" "htop" "obs" "steam" "kitty" "wine" "starship" "zsh"
    "fastfetch" "zsh-autosuggestions" "zsh-syntax-highlighting" "docker" "docker-compose"
    "gh" "rsync" "tmux" "tldr" "jq" "yq" "tree" "bat" "ripgrep" "fd" "mpv"
    "virt-manager" "qemu" "libvirt" "ffmpeg" "thefuck" "scc" "exa" "grex" "navi"
    "git-extras" "progress"
)

APPS_DNF=(
    "git" "neovim" "fzf" "htop" "obs-studio" "steam" "kitty" "wine" "starship" "zsh"
    "fastfetch" "zsh-autosuggestions" "zsh-syntax-highlighting" "docker" "docker-compose"
    "podman" "gh" "rsync" "tmux" "tldr" "jq" "yq" "tree" "bat" "ripgrep" "fd" "mpv"
    "virt-manager" "qemu" "libvirt" "ffmpeg" "thefuck" "scc" "exa" "grex" "navi"
    "git-extras" "progress"
)

APPS_YAY=(
    "git" "neovim" "fzf" "htop" "obs-studio" "steam" "kitty" "wine" "starship" "zsh"
    "fastfetch" "zsh-autosuggestions" "zsh-syntax-highlighting" "docker" "docker-compose"
    "gh" "rsync" "tmux" "tldr" "jq" "yq" "tree" "bat" "ripgrep" "fd" "mpv"
    "virt-manager" "qemu" "libvirt" "ffmpeg" "thefuck" "scc" "exa" "grex" "navi"
    "git-extras" "progress" "google-chrome" "obsidian" "1password" "ghostty"
    "lazyvim" "lazydocker"
)

APPS_FLATPAK=(
    "com.valvesoftware.Steam" "org.prismlauncher.PrismLauncher" "org.freedesktop.Platform"
    "com.obsproject.Studio" "org.libreoffice.LibreOffice"
)

install_brew() {
    echo "Setting up macOS..."
    brew update || true
    install_packages brew "${APPS_BREW[@]}"
}

install_dnf() {
    echo "Setting up Fedora..."
    sudo dnf update -y --refresh || true
    install_packages sudo dnf "${APPS_DNF[@]}"
    
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true
    install_packages sudo flatpak install -y --noninteractive "${APPS_FLATPAK[@]}"
}

install_yay() {
    echo "Setting up Arch Linux..."
    yay -Syu --noconfirm || true
    install_packages yay "${APPS_YAY[@]}"
    
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true
    install_packages sudo flatpak install -y --noninteractive "${APPS_FLATPAK[@]}"
}

install_pacman() {
    echo "Setting up Arch Linux (Pacman only)..."
    sudo pacman -Syu --noconfirm || true
    install_packages sudo pacman -S --noconfirm "${APPS_YAY[@]}"
}

install_manual() {
    echo "Installing manual packages..."
    # Example: JetBrains Toolbox
    if [[ ! -f "/opt/jetbrains-toolbox/jetbrains-toolbox" ]]; then
        echo "Installing JetBrains Toolbox..."
        wget -O /tmp/jetbrains-toolbox.tar.gz https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.28.1.tar.gz
        tar -xzf /tmp/jetbrains-toolbox.tar.gz -C /opt/
        sudo mv /opt/jetbrains-toolbox-*/ /opt/jetbrains-toolbox/
    fi
}

case "$PACKAGE_MANAGER" in
    brew) install_brew ;;
    dnf) install_dnf ;;
    yay) install_yay ;;
    pacman) install_pacman ;;
    *) echo "Unsupported package manager: $PACKAGE_MANAGER" ; exit 1 ;;
esac

install_manual

echo "System bootstrap completed! Reboot recommended."

