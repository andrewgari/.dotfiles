#!/bin/bash

# Script to sync dotfiles between local and remote repository
DOTFILES_REPO=git@github.com:andrewgari/.dotfiles
DOTFILES_DIR=~/Repos/dotfiles
BACKUP_DIR=~/backups/dotfiles

# Clone the repository if it doesn't exist
if [ ! -d "$DOTFILES_DIR/.git" ]; then
    echo "📥 Cloning dotfiles repository..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# Backup existing home dotfiles that are tracked in the repository
mkdir -p "$BACKUP_DIR"
cd "$DOTFILES_DIR"
for file in $(find . -type f -not -path "./systemd/*"); do
    home_file="$HOME/${file#./}"
    backup_file="$BACKUP_DIR/${file#./}"
    
    if [ -f "$home_file" ]; then
        mkdir -p "$(dirname "$backup_file")"
        cp "$home_file" "$backup_file"
        echo "💾 Backed up existing home file: $home_file to $backup_file"
    fi
done

# Copy local changes from home to repo directory
for file in $(find "$HOME" -type f -path "$HOME/.*" -not -path "$HOME/Repos/*"); do
    repo_file="$DOTFILES_DIR/${file#$HOME/}"
    mkdir -p "$(dirname "$repo_file")"
    cp "$file" "$repo_file"
    echo "🔄 Copied $file to repo directory."
done

# Pull latest changes and rebase
echo "🔄 Fetching and rebasing latest dotfiles updates..."
cd "$DOTFILES_DIR"
git fetch --all
git rebase origin/main || {
    echo "⚠️ Merge conflicts detected. Please resolve manually."
    exit 1
}

git add .
git commit -m "Syncing dotfiles" --allow-empty

git push origin main

# Copy latest files from repo to home (excluding systemd)
for file in $(find . -type f -not -path "./systemd/*"); do
    dest="$HOME/${file#./}"
    mkdir -p "$(dirname "$dest")"
    cp "$file" "$dest"
    echo "✅ Updated $dest"
done

echo "🎉 Dotfiles sync complete!"

