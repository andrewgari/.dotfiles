#!/bin/bash

set -e  # Exit on error

# Define Constants
REPO_URL="http://github.com/andrewgari/.dotfiles"
TARGET_DIR="$HOME/Repos/.dotfiles"
BACKUP_DIR="$HOME/dotfiles_backup"
TOOLBOX_URL="https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.28.1.tar.gz"
TOOLBOX_DIR="$HOME/.jetbrains-toolbox"
TOOLBOX_TMP="/tmp/jetbrains-toolbox.tar.gz"
DRY_RUN=false  # Default mode

# Ask user whether to enable dry-run mode
echo -n "Enable Dry-Run mode? (y/N): "
read -r dry_choice
if [[ "$dry_choice" =~ ^[Yy]$ ]]; then
    DRY_RUN=true
    echo "[Dry-Run Mode Enabled] No actual changes will be made."
fi

# Detect Package Manager (Prefers `yay` over `pacman` if available)
detect_package_manager() {
    if command -v yay &> /dev/null; then
        PM="yay"
    elif command -v dnf &> /dev/null; then
        PM="dnf"
    elif command -v apt &> /dev/null; then
        PM="apt"
    elif command -v pacman &> /dev/null; then
        PM="pacman"
    elif command -v brew &> /dev/null; then
        PM="brew"
    elif command -v flatpak &> /dev/null; then
        PM="flatpak"
    else
        echo "Unsupported package manager. Install required apps manually."
        exit 1
    fi
}

# Verify package availability
check_package_existence() {
    local package=$1
    case $PM in
        yay) yay -Si "$package" &> /dev/null ;;
        dnf) sudo dnf list --available "$package" &> /dev/null ;;
        apt) apt-cache show "$package" &> /dev/null ;;
        pacman) pacman -Si "$package" &> /dev/null ;;
        brew) brew info "$package" &> /dev/null ;;
        flatpak) flatpak search "$package" &> /dev/null ;;
        *) return 1 ;;
    esac
    return $?  # Returns 0 if the package exists, otherwise 1
}

# Install necessary system packages (Excluding VSCode)
install_packages() {
    echo "Installing essential packages..."
    
    packages=(
        git git-extras gh lazygit ghostty docker docker-compose lazydocker android-tools
        neovim fzf ripgrep bat htop wget unzip tar curl
    )

    if [ "$DRY_RUN" = true ]; then
        echo "[Dry-Run] Checking availability of packages..."
        for pkg in "${packages[@]}"; do
            if check_package_existence "$pkg"; then
                echo "[✔] $pkg is available in $PM"
            else
                echo "[✖] $pkg NOT FOUND in $PM"
            fi
        done
        return
    fi

    case $PM in
        yay) yay -S --noconfirm "${packages[@]}" ;;
        dnf) sudo dnf install -y "${packages[@]}" --skip-unavailable ;;
        apt) sudo apt update && sudo apt install -y "${packages[@]}" ;;
        pacman) sudo pacman -S --noconfirm "${packages[@]}" ;;
        brew) brew install "${packages[@]}" ;;
        flatpak) echo "[Skipping: Flatpak not needed for system packages]" ;;
        *) echo "Unsupported package manager."; exit 1 ;;
    esac
}

# Install VSCode & Extensions (Only if not already installed)
install_vscode() {
    if command -v code &> /dev/null; then
        echo "VSCode is already installed."
        return
    fi

    echo "Installing VSCode..."
    if [ "$DRY_RUN" = true ]; then
        echo "[Dry-Run] Checking if VSCode is available..."
        if check_package_existence "code"; then
            echo "[✔] VSCode is available in $PM"
        else
            echo "[✖] VSCode NOT FOUND in $PM"
        fi
        return
    fi

    case $PM in
        yay) yay -S --noconfirm code ;;
        dnf) sudo dnf install -y code ;;
        apt) sudo apt install -y code ;;
        pacman) sudo pacman -S --noconfirm code ;;
        brew) brew install --cask visual-studio-code ;;
        flatpak) flatpak install -y flathub com.visualstudio.code ;;
    esac
}

# Setup Docker
install_docker() {
    echo "Setting up Docker..."
    
    if [ "$DRY_RUN" = true ]; then
        echo "[Dry-Run] Would enable and configure Docker"
        return
    fi

    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER
}

# Setup Docker Network
setup_docker_network() {
    echo "Setting up Docker network..."
    docker network create dev-network || true
}

# Create Development Containers
create_dev_containers() {
    echo "Creating development containers..."
    
    containers=(
        "java-dev openjdk:latest $HOME/dev/java"
        "kotlin-dev gradle:latest $HOME/dev/kotlin"
        "golang-dev golang:latest $HOME/dev/go"
        "rust-dev rust:latest $HOME/dev/rust"
        "node-dev node:latest $HOME/dev/node"
        "python-dev python:latest $HOME/dev/python"
        "android-dev ghcr.io/cirruslabs/android-sdk:latest $HOME/dev/android"
    )

    for container in "${containers[@]}"; do
        set -- $container
        name=$1
        image=$2
        volume=$3

        if [ "$DRY_RUN" = true ]; then
            echo "[Dry-Run] Would create container: $name using image: $image"
            continue
        fi

        docker run -d --name "$name" --network dev-network -v "$volume:/workspace" -w /workspace "$image" tail -f /dev/null
    done
}

# Verify Installations
verify_installations() {
    echo "Verifying installations..."
    
    echo "Checking installed applications..."
    apps=(git gh lazygit ghostty docker docker-compose lazydocker neovim fzf ripgrep bat htop)

    for app in "${apps[@]}"; do
        if command -v "$app" &> /dev/null; then
            echo "[✔] $app is installed"
        else
            echo "[✖] $app is missing"
        fi
    done

    echo "Checking Docker containers..."
    docker ps --format "table {{.Names}}\t{{.Status}}"

    echo "Checking VSCode extensions..."
    code --list-extensions
}

# Execute functions
detect_package_manager
install_packages
install_docker
install_vscode
setup_docker_network
create_dev_containers

verify_installations

echo "All development tools and configurations have been set up successfully! 🚀"
