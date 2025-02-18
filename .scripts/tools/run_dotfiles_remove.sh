#!/bin/bash

# Script to remove dotfiles from the dotfiles repository
DOTFILES_REPO=git@github.com:andrewgari/.dotfiles
DOTFILES_DIR=~/Repos/dotfiles

# Clone the repository if it doesn't exist
if [ ! -d "$DOTFILES_DIR/.git" ]; then
    echo "📥 Cloning dotfiles repository..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

if [ -z "$1" ]; then
    echo "❌ Please specify a file to remove."
    exit 1
fi

file_path=$(realpath "$1")
relative_path="${file_path#$HOME/}"
target_path="$DOTFILES_DIR/$relative_path"

if [ -f "$target_path" ]; then
    echo "🗑 Removing $target_path from dotfiles repository..."
    rm "$target_path"
    cd "$DOTFILES_DIR"
    git rm "$relative_path"
    echo "✅ Successfully removed $relative_path from dotfiles repository."
else
    echo "⚠️ File $relative_path does not exist in the repository."
fi

