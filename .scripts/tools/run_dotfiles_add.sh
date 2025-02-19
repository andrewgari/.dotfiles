#!/bin/zsh

# Configuration
DOTFILES_REPO=git@github.com:andrewgari/.dotfiles
DOTFILES_DIR=~/Repos/dotfiles
SCRIPTS_DIR="$HOME/.scripts"  # Directory to always sync

# Ensure the dotfiles repo exists
if [ ! -d "$DOTFILES_DIR/.git" ]; then
    echo "📥 Cloning dotfiles repository..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
    echo "📝 Stashing any local changes before pulling..."
    
    # Change to repo directory
    cd "$DOTFILES_DIR" || exit

    # Stash changes before pulling (only if there are unstaged modifications)
    if ! git diff --quiet || ! git diff --cached --quiet; then
        git stash push -m "Auto-stash before pull ($(date +'%Y-%m-%d %H:%M:%S'))"
    fi

    echo "🔄 Pulling latest changes from remote..."
    git pull --rebase

    # Restore stashed changes if there are any
    if git stash list | grep -q "Auto-stash before pull"; then
        echo "♻️ Reapplying stashed changes..."
        if ! git stash apply; then
            echo "⚠️ Merge conflicts detected while applying stashed changes."
            echo "🛠️ Please resolve conflicts manually."
            exit 1
        fi
        git stash drop  # Remove stash only after successful apply
    fi
fi

echo "🔍 Checking for modified dotfiles..."

# Find and sync modified files
git -C "$DOTFILES_DIR" ls-files -z | while IFS= read -r -d '' file; do
    home_file="$HOME/$file"
    repo_file="$DOTFILES_DIR/$file"

    if [ -f "$home_file" ]; then
        if ! diff -q "$home_file" "$repo_file" >/dev/null 2>&1; then
            echo "📂 Updating changed file: $file"

            # Print exact rsync command
            echo "rsync -avu \"$home_file\" \"$repo_file\""

            # Sync file to repo only if newer
            rsync -avu "$home_file" "$repo_file"

            git -C "$DOTFILES_DIR" add "$file"
        fi
    fi
done

echo "📂 Syncing all files from .scripts/"

# Ensure the target directory exists in the repo
mkdir -p "$DOTFILES_DIR/.scripts"

# Sync entire .scripts directory (only update newer files)
echo "rsync -avu \"$SCRIPTS_DIR/\" \"$DOTFILES_DIR/.scripts/\""
rsync -avu "$SCRIPTS_DIR/" "$DOTFILES_DIR/.scripts/"

# Stage everything inside .scripts/
git -C "$DOTFILES_DIR" add .scripts/

echo "🗑️ Removing files from git that no longer exist in .scripts/..."
# Find files tracked in the repo under .scripts/ that no longer exist in the actual .scripts directory
git -C "$DOTFILES_DIR" ls-files ".scripts" -z | while IFS= read -r -d '' repo_file; do
    if [ ! -e "$SCRIPTS_DIR/${repo_file#".scripts/"}" ]; then
        echo "❌ Removing stale file from git: $repo_file"
        git -C "$DOTFILES_DIR" rm --cached "$repo_file"
        rm -f "$DOTFILES_DIR/$repo_file"
    fi
done

echo "✅ Dotfiles sync complete. Staged new and updated files, removed stale ones, but did not commit."

