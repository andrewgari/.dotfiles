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

# Function to configure Neovim using ThePrimeagen's guides
configure_nvim() {
    echo "Setting up Neovim..."
    mkdir -p "$HOME/.config/nvim"
    cat > "$HOME/.config/nvim/init.lua" <<EOF
require'packer'.startup(function()
    use 'wbthomason/packer.nvim'
    use {
        'neovim/nvim-lspconfig',
        config = function()
            require'lspconfig'.tsserver.setup{}
            require'lspconfig'.gopls.setup{}
            require'lspconfig'.rust_analyzer.setup{}
            require'lspconfig'.jdtls.setup{}
            require'lspconfig'.kotlin_language_server.setup{}
            require'lspconfig'.pyright.setup{}
            require'lspconfig'.dockerls.setup{}
            require'lspconfig'.bashls.setup{}
            require'lspconfig'.jsonls.setup{}
            require'lspconfig'.yamlls.setup{}
            require'lspconfig'.taplo.setup{}
            require'lspconfig'.lemminx.setup{}
        end
    }
    use {
        'nvim-telescope/telescope.nvim',
        requires = { {'nvim-lua/plenary.nvim'} }
    }
    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    }
    use 'ThePrimeagen/harpoon'
    use 'nvim-lua/plenary.nvim'
end)

require'telescope'.setup{}
require'treesitter'.setup{}
EOF
}

# Function to set up development containers
setup_dev_containers() {
    echo "Setting up development containers..."
    mkdir -p "$HOME/DevContainers"
    cat > "$HOME/DevContainers/docker-compose.yml" <<EOF
version: '3'
services:
  node:
    image: node:latest
    volumes:
      - .:/workspace
    command: /bin/sh
  golang:
    image: golang:latest
    volumes:
      - .:/workspace
    command: /bin/sh
  rust:
    image: rust:latest
    volumes:
      - .:/workspace
    command: /bin/sh
  java:
    image: openjdk:latest
    volumes:
      - .:/workspace
    command: /bin/sh
  kotlin:
    image: openjdk:latest
    volumes:
      - .:/workspace
    command: /bin/sh
  python:
    image: python:latest
    volumes:
      - .:/workspace
    command: /bin/sh
EOF
}

install_docker
install_vscode
install_android_tools
configure_nvim
setup_dev_containers

echo "Development environment setup completed!"

