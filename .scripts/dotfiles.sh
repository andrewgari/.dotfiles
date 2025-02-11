#!/bin/bash

set -e  # Exit on error

DOTFILES_REPO="git@github.com:andrewgari/.dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup"

backup_existing_dotfiles() {
    echo "Backing up existing dotfiles..."
    mkdir -p "$BACKUP_DIR"
    for file in .zshrc .vimrc .config/nvim .gitconfig .config/kitty; do
        if [ -e "$HOME/$file" ]; then
            mv "$HOME/$file" "$BACKUP_DIR/"
        fi
    done
}

clone_or_pull_dotfiles() {
    if [ -d "$DOTFILES_DIR" ]; then
        echo "Updating existing dotfiles repository..."
        git -C "$DOTFILES_DIR" pull
    else
        echo "Cloning dotfiles repository..."
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    fi
}

apply_dotfiles() {
    echo "Applying dotfiles from home directory..."
    cp -r "$DOTFILES_DIR/." "$HOME/"
}

backup_existing_dotfiles
clone_or_pull_dotfiles
apply_dotfiles

echo "Dotfiles sync and application completed!"

