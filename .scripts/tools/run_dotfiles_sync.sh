#!/bin/bash

# Live script to sync dotfiles between local and remote repository
DOTFILES_REPO=git@github.com:andrewgari/.dotfiles
DOTFILES_DIR=~/Repos/dotfiles
BACKUP_BASE_DIR=~/backups/dotfiles
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_DIR="$BACKUP_BASE_DIR-$TIMESTAMP"

echo "🚀 Starting dotfiles sync..."

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

# Sync only tracked files from home to repo
echo "🔄 Copying tracked files from home to repo directory..."
for file in $(git ls-files | grep -v '^systemd/'); do
    home_file="$HOME/$file"
    repo_file="$DOTFILES_DIR/$file"
    
    if [ -f "$home_file" ]; then
        mkdir -p "$(dirname "$repo_file")"
        rsync -a "$home_file" "$repo_file"
        echo "🔄 Updated: $home_file -> $repo_file"
    fi
done

# Stage, check for changes, and commit
if git diff --cached --quiet; then
    echo "✅ No changes to commit."
else
    LAST_COMMIT_MSG=$(git log -1 --pretty=%s)
    CHANGED_FILES=$(git diff --cached --name-only | sed 's/^/- /')
    if [[ "$LAST_COMMIT_MSG" =~ ^🔄\ Automated\ sync\ of\ dotfiles ]]; then
        echo "🔄 Amending last commit..."
        git commit --amend -m "🔄 Automated sync of dotfiles

Changed files:\n$CHANGED_FILES"
    else
        echo "📝 Creating a new commit..."
        git commit -m "🔄 Automated sync of dotfiles\n\nChanged files:\n$CHANGED_FILES"
    fi
    git push origin main
fi

echo "🎉 Dotfiles sync complete!"


