#!/bin/bash

set -e  # Exit on error

# Detect package manager
if [[ "$(uname)" == "Darwin" ]]; then
    PACKAGE_MANAGER="brew"
elif command -v dnf &>/dev/null; then
    PACKAGE_MANAGER="dnf"
elif command -v yay &>/dev/null; then
    PACKAGE_MANAGER="yay"
elif command -v pacman &>/dev/null; then
    PACKAGE_MANAGER="pacman"
elif command -v apt &>/dev/null; then
    PACKAGE_MANAGER="apt"
else
    echo "Unsupported package manager" >&2
    exit 1
fi

# System-wide applications
APPS_PACKAGE_MANAGER=(
    "git" "neovim" "fzf" "htop" "starship" "fastfetch" "zsh" "wget"
    "zsh-autosuggestions" "zsh-syntax-highlighting" "docker" "docker-compose"
    "podman" "gh" "rsync" "tmux" "tldr" "jq" "yq" "tree" "bat" "ripgrep"
    "fd" "virt-manager" "qemu" "libvirt" "ffmpeg" "thefuck" "scc" "exa" "ghostty"
    "navi" "git-extras" "progress" "android-tools" "google-chrome" "flatpak"
)

# Brew-specific packages
if [[ "$PACKAGE_MANAGER" == "brew" ]]; then
    APPS_PACKAGE_MANAGER+=(
        "raycast"
    )
fi

# Flatpak package mapping
declare -A FLATPAK_MAPPING=(
    ["retroarch"]="org.libretro.RetroArch"
    ["ppsspp"]="org.ppsspp.PPSSPP"
    ["duckstation"]="org.duckstation.DuckStation"
    ["pcsx2"]="net.pcsx2.PCSX2"
    ["yuzu"]="org.yuzu_emu.yuzu"
    ["rpcs3"]="net.rpcs3.RPCS3"
    ["dolphin"]="org.DolphinEmu.dolphin-emu"
    ["prism-launcher"]="org.prismlauncher.PrismLauncher"
    ["obs-studio"]="com.obsproject.Studio"
    ["steam"]="com.valvesoftware.Steam"
    ["discord"]="com.discordapp.Discord"
    ["libreoffice"]="org.libreoffice.LibreOffice"
    ["kdenlive"]="org.kde.kdenlive"
    ["flatseal"]="com.github.tchx84.Flatseal"
    ["obsidian"]="md.obsidian.Obsidian"
    ["bottles"]="com.usebottles.bottles"
    ["lutris"]="net.lutris.Lutris"
    ["wine"]="org.winehq.Wine"
    ["vlc"]="org.videolan.VLC"
    ["vesktop"]="dev.vencord.Vesktop"
)

APPS_FLATPAK=(${FLATPAK_MAPPING[@]})

# Install system packages
echo "📦 Installing system packages..."
case "$PACKAGE_MANAGER" in
    dnf) sudo dnf install -y --skip-unavailable "${APPS_PACKAGE_MANAGER[@]}" ;;
    pacman) sudo pacman -S --noconfirm "${APPS_PACKAGE_MANAGER[@]}" ;;
    apt) sudo apt install -y "${APPS_PACKAGE_MANAGER[@]}" ;;
    brew) brew install ${APPS_PACKAGE_MANAGER[@]} || echo "⚠️  Some packages may not be available on Homebrew." ;;
esac

# Install Flatpak applications if not on macOS
if [[ "$PACKAGE_MANAGER" != "brew" ]]; then
    echo "📦 Installing Flatpak applications..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true
    for app in "${!FLATPAK_MAPPING[@]}"; do
        package_name="${FLATPAK_MAPPING[$app]}"
        if ! flatpak list --user | grep -q "$package_name"; then
            echo "🚀 Installing: $app ($package_name)"
            if ! flatpak install --user -y --noninteractive "$package_name" 2>/tmp/flatpak_error.log; then
                echo "❌ Failed to install: $app ($package_name)"
                echo "💡 Command: flatpak install --user -y --noninteractive $package_name"
                echo "🔍 Error Details:"
                cat /tmp/flatpak_error.log
            else
                echo "✅ Installed: $app ($package_name)"
            fi
        else
            echo "✔ Already installed: $app ($package_name)"
        fi
    done
fi

# Install NerdFonts
echo "🎨 Installing NerdFonts..."
FONT_DIR="$HOME/.local/share/fonts/NerdFonts"
mkdir -p "$FONT_DIR"
wget -qO "$FONT_DIR/FiraCode.zip" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"
unzip -qo "$FONT_DIR/FiraCode.zip" -d "$FONT_DIR"
fc-cache -f

echo "🎉 System bootstrap completed! Reboot recommended."
