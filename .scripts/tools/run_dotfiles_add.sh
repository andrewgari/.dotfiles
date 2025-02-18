#!/bin/bash

# Script to add dotfiles to the dotfiles repository
DOTFILES_REPO=git@github.com:andrewgari/.dotfiles
DOTFILES_DIR=~/Repos/dotfiles

# Clone the repository if it doesn't exist
if [ ! -d "$DOTFILES_DIR/.git" ]; then
    echo "📥 Cloning dotfiles repository..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

if [ -z "$1" ]; then
    echo "❌ Please specify a file to add."
    exit 1
fi

file_path=$(realpath "$1")
relative_path="${file_path#$HOME/}"
target_path="$DOTFILES_DIR/$relative_path"

echo "📂 Copying $file_path to $target_path..."
mkdir -p "$(dirname "$target_path")"
cp "$file_path" "$target_path"

echo "📌 Adding $target_path to git repository..."
cd "$DOTFILES_DIR"
git add "$relative_path"

echo "✅ Successfully added $relative_path to dotfiles repository."

