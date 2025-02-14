#!/bin/bash

set -e  # Exit on error

# Function to install Docker if not installed
install_docker() {
    if ! command -v docker &> /dev/null; then
        echo "Installing Docker..."
        if command -v dnf &> /dev/null; then
            sudo dnf install -y docker docker-compose --skip-unavailable
        elif command -v apt &> /dev/null; then
            sudo apt update && sudo apt install -y docker.io docker-compose
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm docker docker-compose
        else
            echo "Unsupported package manager. Install Docker manually."
            exit 1
        fi
        sudo systemctl enable --now docker
        sudo usermod -aG docker $USER
    fi
}

# Function to install VSCode and extensions
install_vscode() {
    if ! command -v code &> /dev/null; then
        echo "Installing VSCode..."
        if command -v dnf &> /dev/null; then
            sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
            echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
            dnf check-update
            sudo dnf install code # or code-insiders
        elif command -v apt &> /dev/null; then
            sudo apt install -y code
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm code
        else
            echo "Unsupported package manager. Install VSCode manually."
            exit 1
        fi
    fi
    echo "Installing VSCode extensions..."
    code --install-extension ms-vscode.vscode-typescript-next
    code --install-extension golang.go
    code --install-extension rust-lang.rust-analyzer
    code --install-extension redhat.java
    code --install-extension fwcd.kotlin
    code --install-extension ms-python.python
    # code --install-extension ms-android.vscode-android
    # code --install-extension ms-vscode.vscode-json
    code --install-extension redhat.vscode-yaml
    code --install-extension bungcip.better-toml
    code --install-extension dotjoshjohnson.xml
}

# Function to install ADB and scrcpy
install_android_tools() {
    echo "Installing Android Platform Tools (ADB) and scrcpy..."
    if command -v dnf &> /dev/null; then
        sudo dnf install -y android-tools scrcpy --skip-unavailable
    elif command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y adb scrcpy
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm android-tools scrcpy
    else
        echo "Unsupported package manager. Install ADB and scrcpy manually."
        exit 1
    fi
}

# Function to install JetBrains Toolbox
install_jetbrains_toolbox() {
    echo "Installing JetBrains Toolbox..."
    TOOLBOX_URL="https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.28.1.tar.gz"
    TOOLBOX_DIR="$HOME/.jetbrains-toolbox"
    TOOLBOX_TMP="/tmp/jetbrains-toolbox.tar.gz"
    
    mkdir -p "$TOOLBOX_DIR"
    wget -O "$TOOLBOX_TMP" "$TOOLBOX_URL"
    tar -xzf "$TOOLBOX_TMP" -C "$TOOLBOX_DIR" --strip-components=1
    rm "$TOOLBOX_TMP"
    echo "JetBrains Toolbox installed successfully in $TOOLBOX_DIR"
}

# Function to create a Docker network for dev environments
setup_docker_network() {
    docker network create dev-network || true
}

# Function to create a Docker container for a development environment
create_dev_container() {
    local name=$1
    local image=$2
    local volumes=$3
    local extra_args=$4

    echo "Setting up $name development container..."
    docker run -d --name "$name" --network dev-network $volumes $extra_args "$image" tail -f /dev/null
}

# Function to configure VS Code for Docker development
configure_vscode() {
    mkdir -p "$HOME/.vscode-server"
    cat > "$HOME/.vscode-server/settings.json" <<EOL
{
    "workbench.colorThemme": "GitHub Dark",
    "remote.containers.dockerPath": "docker",
    "remote.containers.defaultExtensions": [
        "ms-vscode-remote.remote-containers",
        "ms-python.python",
        "golang.go",
        "rust-lang.rust-analyzer",
        "redhat.java",
        "vscjava.vscode-java-pack",
        "esbenp.prettier-vscode",
        "dbaeumer.vscode-eslint"
    ]
}
EOL
}

# Function to set up development environments
setup_dev_environments() {
    echo "Setting up development environments..."
    create_dev_container "java-dev" "openjdk:latest" "-v $HOME/dev/java:/workspace" "-w /workspace"
    create_dev_container "kotlin-dev" "gradle:latest" "-v $HOME/dev/kotlin:/workspace" "-w /workspace"
    create_dev_container "golang-dev" "golang:latest" "-v $HOME/dev/go:/workspace" "-w /workspace"
    create_dev_container "rust-dev" "rust:latest" "-v $HOME/dev/rust:/workspace" "-w /workspace"
    create_dev_container "node-dev" "node:latest" "-v $HOME/dev/node:/workspace" "-w /workspace"
    create_dev_container "python-dev" "python:latest" "-v $HOME/dev/python:/workspace" "-w /workspace"
    create_dev_container "android-dev" "ghcr.io/cirruslabs/android-sdk:latest" "-v $HOME/dev/android:/workspace" "-w /workspace"
}

# Function to set up development containers
install_docker
install_vscode
install_jetbrains_toolbox
install_android_tools
echo "Development tools installed!"

# Execute setup functions
setup_docker_network
setup_dev_environments
configure_vscode

echo "Development containers have been set up successfully. Use VS Code Remote-Containers to connect."


