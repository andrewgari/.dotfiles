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
    elif command -v apt &> /dev/null; then
        echo "apt"
    else
        echo "Unsupported package manager" >&2
        exit 1
    fi
}

PACKAGE_MANAGER=$(detect_package_manager)

# Flatpak package mapping
declare -A FLATPAK_MAPPING=(
    ["obs-studio"]="com.obsproject.Studio"
    ["steam"]="com.valvesoftware.Steam"
    ["discord"]="com.discordapp.Discord"
    ["libreoffice"]="org.libreoffice.LibreOffice"
    ["kdenlive"]="org.kde.kdenlive"
    ["sioyek"]="io.github.ahrm.sioyek"
    ["flatseal"]="com.github.tchx84.Flatseal"
    ["obsidian"]="md.obsidian.Obsidian"
    ["ghostty"]="dev.crosscode.Ghostty"
    ["1password"]="com.1password.PasswordManager"
    ["bottles"]="com.usebottles.bottles"
    ["lutris"]="net.lutris.Lutris"
    ["wine"]="org.winehq.Wine"
    ["vlc"]="org.videolan.VLC"
    ["vesktop"]="io.github.nextsquared.vesktop"
)

# Flatpak Apps List (User Scope)
APPS_FLATPAK=("${FLATPAK_MAPPING[@]}")

# System-wide applications (not Flatpak)
APPS_PACKAGE_MANAGER=(
    "git" "neovim" "fzf" "htop" "starship" "fastfetch" "zsh"
    "zsh-autosuggestions" "zsh-syntax-highlighting" "docker" "docker-compose"
    "podman" "gh" "rsync" "tmux" "tldr" "jq" "yq" "tree" "bat" "ripgrep"
    "fd" "virt-manager" "qemu" "libvirt" "ffmpeg" "thefuck" "scc" "exa"
    "grex" "navi" "git-extras" "progress" "android-tools" "google-chrome"
)

# 🛠 **Function to Test Package Availability**
dnf_dry_run() {
    echo "Testing DNF package availability..."
    for pkg in "${APPS_PACKAGE_MANAGER[@]}"; do
        if ! sudo dnf list --available "$pkg" &>/dev/null; then
            echo "⚠️  Warning: Package '$pkg' not found in DNF repositories!"
        else
            echo "✅ DNF Package exists: $pkg"
        fi
    done
}

apt_dry_run() {
    echo "Testing APT package availability..."
    for pkg in "${APPS_PACKAGE_MANAGER[@]}"; do
        if ! apt-cache show "$pkg" &>/dev/null; then
            echo "⚠️  Warning: Package '$pkg' not found in APT repositories!"
        else
            echo "✅ APT Package exists: $pkg"
        fi
    done
}

yay_dry_run() {
    echo "Testing Yay package availability..."
    for pkg in "${APPS_PACKAGE_MANAGER[@]}"; do
        if ! yay -Si "$pkg" &>/dev/null; then
            echo "⚠️  Warning: Package '$pkg' not found in AUR repositories!"
        else
            echo "✅ Yay Package exists: $pkg"
        fi
    done
}

pacman_dry_run() {
    echo "Testing Pacman package availability..."
    for pkg in "${APPS_PACKAGE_MANAGER[@]}"; do
        if ! pacman -Si "$pkg" &>/dev/null; then
            echo "⚠️  Warning: Package '$pkg' not found in Pacman repositories!"
        else
            echo "✅ Pacman Package exists: $pkg"
        fi
    done
}

flatpak_dry_run() {
    echo "Testing Flatpak package availability..."
    for app in "${APPS_FLATPAK[@]}"; do
        if ! flatpak search "$app" &>/dev/null; then
            echo "⚠️  Warning: Flatpak package '$app' not found in Flathub!"
        else
            echo "✅ Flatpak exists: $app"
        fi
    done
}

brew_dry_run() {
    echo "Testing Brew package availability..."
    for pkg in "${APPS_PACKAGE_MANAGER[@]}"; do
        if ! brew info "$pkg" &>/dev/null; then
            echo "⚠️  Warning: Brew package '$pkg' not found!"
        else
            echo "✅ Brew Package exists: $pkg"
        fi
    done
}

# 🛠 **Function to Install Flatpak Apps**
install_flatpak() {
    echo "Installing Flatpak applications..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true
    for app in "${APPS_FLATPAK[@]}"; do
        if ! flatpak list --user | grep -q "$app"; then
            echo "Installing Flatpak: $app"
            flatpak install --user -y --noninteractive "$app"
        else
            echo "Flatpak $app is already installed, skipping."
        fi
    done
}

# 🛠 **Function to Install System Apps via Package Manager**
install_package_manager_apps() {
    echo "Installing system-integrated apps via $PACKAGE_MANAGER..."
    case "$PACKAGE_MANAGER" in
        dnf) sudo dnf install -y "${APPS_PACKAGE_MANAGER[@]}" ;;
        pacman) sudo pacman -S --noconfirm "${APPS_PACKAGE_MANAGER[@]}" ;;
        apt) sudo apt install -y "${APPS_PACKAGE_MANAGER[@]}" ;;
    esac
}

# 🛠 **Function to Install NerdFonts Manually**
install_nerdfonts() {
    echo "Installing NerdFonts..."
    local font_dir="$HOME/.local/share/fonts/NerdFonts"
    mkdir -p "$font_dir"
    wget -O "$font_dir/FiraCode.zip" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"
    unzip -o "$font_dir/FiraCode.zip" -d "$font_dir"
    fc-cache -fv
}

# 🛠 **Run the appropriate install functions**
case "$PACKAGE_MANAGER" in
    brew)
        echo "Setting up macOS..."
        brew update || true
        brew install "ghostty" "zsh" "git"
        ;;
    dnf)
        sudo dnf update -y --refresh || true
        install_package_manager_apps
        ;;
    yay)
        yay -Syu --noconfirm || true
        install_package_manager_apps
        ;;
    pacman)
        sudo pacman -Syu --noconfirm || true
        install_package_manager_apps
        ;;
    apt)
        sudo apt update -y && sudo apt upgrade -y
        install_package_manager_apps
        ;;
    *)
        echo "Unsupported package manager: $PACKAGE_MANAGER"
        exit 1
        ;;
esac

# 🚀 **Install Flatpak Applications**
install_flatpak

# 🚀 **Install NerdFonts**
install_nerdfonts

echo "🎉 System bootstrap completed! Reboot recommended."

