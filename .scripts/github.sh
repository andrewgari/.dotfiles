#!/bin/bash

set -e  # Exit on error

GITHUB_USERNAME="andrewgari"
GITHUB_EMAIL="covadax.ag@gmail.com"
GIT_CONFIG_DIR="$HOME/.config/git"
GIT_CREDENTIALS_FILE="$GIT_CONFIG_DIR/credentials"
KEY_DIR="$HOME/.ssh"
KEY_FILE="$KEY_DIR/github_rsa"

configure_git() {
    echo "Configuring Git..."
    git config --global user.name "$GITHUB_USERNAME"
    git config --global user.email "$GITHUB_EMAIL"
    git config --global core.editor "nvim"
    git config --global credential.helper store
    git config --global init.defaultBranch main
}

configure_github_pat() {
    echo "Setting up GitHub PAT authentication..."
    mkdir -p "$GIT_CONFIG_DIR"
    read -sp "Enter your GitHub PAT: " GITHUB_PAT
    echo
    echo "https://$GITHUB_USERNAME:$GITHUB_PAT@github.com" > "$GIT_CREDENTIALS_FILE"
    chmod 600 "$GIT_CREDENTIALS_FILE"
}

configure_github_cli() {
    echo "Configuring GitHub CLI (gh)..."
    if ! command -v gh &> /dev/null; then
        echo "GitHub CLI (gh) not found. Installing..."
        if command -v dnf &> /dev/null; then
            sudo dnf install -y gh
        elif command -v apt &> /dev/null; then
            sudo apt update && sudo apt install -y gh
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm github-cli
        else
            echo "Unsupported package manager. Install GitHub CLI manually."
            exit 1
        fi
    fi
    gh auth login --with-token <<< "$GITHUB_PAT"
}

configure_github_copilot() {
    echo "Setting up GitHub Copilot..."
    if gh extension list | grep -q "copilot"; then
        echo "GitHub Copilot CLI already installed."
    else
        gh extension install github/gh-copilot
    fi
}

# Function to generate a new SSH key for GitHub
generate_ssh_key() {
    echo "Generating a new SSH key for GitHub..."
    mkdir -p "$KEY_DIR"
    if [ -f "$KEY_FILE" ]; then
        echo "SSH key already exists at $KEY_FILE"
    else
        ssh-keygen -t rsa -b 4096 -C "$GITHUB_EMAIL" -f "$KEY_FILE" -N ""
        eval "$(ssh-agent -s)"
        ssh-add "$KEY_FILE"
    fi
}

# Function to display SSH public key for GitHub setup
display_ssh_key() {
    echo "Add the following SSH key to your GitHub account:"
    echo "----------------------------------"
    cat "$KEY_FILE.pub"
    echo "----------------------------------"
}

# Function to add key to GitHub using gh CLI
add_key_to_github() {
    if command -v gh &> /dev/null; then
        echo "Adding SSH key to GitHub..."
        gh auth login
        gh ssh-key add "$KEY_FILE.pub" --title "$(hostname) GitHub Key"
    else
        echo "GitHub CLI (gh) not installed. Please add the key manually."
    fi
}

configure_git
configure_github_pat
configure_github_cli
configure_github_copilot
generate_ssh_key
display_ssh_key
add_key_to_github

echo "Git, GitHub CLI, Copilot, and SSH key setup completed!"

