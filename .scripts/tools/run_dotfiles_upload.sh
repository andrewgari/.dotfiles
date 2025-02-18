#!/bin/bash

# Live script to push local dotfiles to the remote repository
DOTFILES_REPO=git@github.com:andrewgari/.dotfiles
DOTFILES_DIR=~/Repos/dotfiles
BACKUP_BASE_DIR=~/backups/dotfiles
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_DIR="$BACKUP_BASE_DIR-$TIMESTAMP"

echo "🚀 Starting dotfiles sync to remote..."

# Clone the repository if it doesn't exist
echo "🔍 Checking if repository exists..."
if [ ! -d "$DOTFILES_DIR/.git" ]; then
    echo "📥 Cloning dotfiles repository..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
    echo "✅ Repository already exists."
fi

# Fetch and pull latest changes
echo "🔄 Fetching latest changes from remote repository..."
cd "$DOTFILES_DIR"
git fetch --all
git pull origin main || {
    echo "⚠️ Merge conflicts detected. Launching interactive resolution..."
    git mergetool
    git rebase --continue
}

# Backup existing home dotfiles before updating
echo "💾 Backing up existing home dotfiles to $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"
for file in $(git ls-files | grep -v '^systemd/'); do
    home_file="$HOME/$file"
    backup_file="$BACKUP_DIR/$file"
    
    if [ -f "$home_file" ]; then
        mkdir -p "$(dirname "$backup_file")"
        rsync -a "$home_file" "$backup_file"
        echo "💾 Backed up: $home_file -> $backup_file"
    fi
done

# Keep only the latest 10 backups
BACKUP_COUNT=$(ls -d $BACKUP_BASE_DIR-* 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -gt 10 ]; then
    echo "🗑 Keeping only the latest 10 backups, deleting older ones..."
    ls -d $BACKUP_BASE_DIR-* 2>/dev/null | sort | head -n -10 | xargs rm -rf
fi

# Sync home dotfiles to repo
echo "🔄 Copying local dotfiles to repo directory..."
for file in $(git ls-files | grep -v '^systemd/'); do
    home_file="$HOME/$file"
    repo_file="$DOTFILES_DIR/$file"
    
    if [ -f "$home_file" ]; then
        mkdir -p "$(dirname "$repo_file")"
        rsync -a "$home_file" "$repo_file"
        echo "🔄 Updated: $home_file -> $repo_file"
    fi
done

# Stage, commit, and push changes
echo "📝 Staging all changes in dotfiles repository..."
git add .
git commit -m "🔄 Automated push of local dotfiles"
git push origin main

echo "🎉 Dotfiles push complete!"

