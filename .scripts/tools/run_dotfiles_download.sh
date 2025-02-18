#!/bin/bash

# Live script to update local dotfiles from the remote repository
DOTFILES_REPO=git@github.com:andrewgari/.dotfiles
DOTFILES_DIR=~/Repos/dotfiles

echo "🚀 Starting dotfiles update from remote..."

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

# Sync dotfiles from repo to home
echo "🔄 Copying latest files from repo to home directory..."
for file in $(git ls-files | grep -v '^systemd/'); do
    dest="$HOME/$file"
    repo_file="$DOTFILES_DIR/$file"
    
    if [ -f "$repo_file" ]; then
        mkdir -p "$(dirname "$dest")"
        echo "🔄 Updating: $repo_file -> $dest"
        rsync -a "$repo_file" "$dest"
        echo "✅ Updated: $dest"
    else
        echo "⚠️ File $repo_file does not exist, skipping update."
    fi
done

echo "🎉 Dotfiles update complete!"



