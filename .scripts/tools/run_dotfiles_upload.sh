#!/bin/bash

# Live script to push local dotfiles to the remote repository
DOTFILES_REPO=git@github.com:andrewgari/.dotfiles
DOTFILES_DIR=~/Repos/dotfiles
BACKUP_BASE_DIR=~/backups/dotfiles
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_DIR="$BACKUP_BASE_DIR-$TIMESTAMP"
DRY_RUN=false

# Parse arguments
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "🟡 Running in dry-run mode (no changes will be made)."
fi

# Function to display a progress bar
progress_bar() {
    local total=$1
    local current=$2
    local width=40  # Width of the progress bar

    local progress=$(( current * width / total ))
    local remaining=$(( width - progress ))

    printf "\r["
    printf "%0.s#" $(seq 1 $progress)  # Filled part
    printf "%0.s-" $(seq 1 $remaining)  # Empty part
    printf "] %d%% - Processing: %s" $(( current * 100 / total )) "$3"
}

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
cd "$DOTFILES_DIR" || exit
git fetch --all > /dev/null

if ! git pull origin main > /dev/null 2>&1; then
    echo "⚠️ Merge conflicts detected. Launching interactive resolution..."
    git mergetool
    git rebase --continue
fi

# Get list of dotfiles to sync
file_list=($(git ls-files | grep -v '^systemd/'))
total_files=${#file_list[@]}
current_file=0

# Backup existing home dotfiles before updating
echo "💾 Backing up existing home dotfiles to $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"

for file in "${file_list[@]}"; do
    ((current_file++))
    progress_bar "$total_files" "$current_file" "$file"

    home_file="$HOME/$file"
    backup_file="$BACKUP_DIR/$file"

    if [ -f "$home_file" ]; then
        mkdir -p "$(dirname "$backup_file")"
        if [ "$DRY_RUN" = true ]; then
            echo -e "\n🟡 [Dry Run] Would backup: $home_file -> $backup_file"
        else
            rsync -a "$home_file" "$backup_file" > /dev/null
        fi
    fi
done

# Keep only the latest 10 backups
BACKUP_COUNT=$(ls -d $BACKUP_BASE_DIR-* 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -gt 10 ]; then
    echo "🗑 Keeping only the latest 10 backups, deleting older ones..."
    if [ "$DRY_RUN" = true ]; then
        ls -d $BACKUP_BASE_DIR-* 2>/dev/null | sort | head -n -10 | xargs -I {} echo "🟡 [Dry Run] Would delete: {}"
    else
        ls -d $BACKUP_BASE_DIR-* 2>/dev/null | sort | head -n -10 | xargs rm -rf
    fi
fi

# Sync home dotfiles to repo
echo "🔄 Copying local dotfiles to repo directory..."
current_file=0

for file in "${file_list[@]}"; do
    ((current_file++))
    progress_bar "$total_files" "$current_file" "$file"

    home_file="$HOME/$file"
    repo_file="$DOTFILES_DIR/$file"

    if [ -f "$home_file" ]; then
        mkdir -p "$(dirname "$repo_file")"
        if [ "$DRY_RUN" = true ]; then
            echo -e "\n🟡 [Dry Run] Would update: $home_file -> $repo_file"
        else
            rsync -a "$home_file" "$repo_file" > /dev/null
            git -C "$DOTFILES_DIR" add "$repo_file"
        fi
    fi
done

# Stage, check for changes, and commit
if git -C "$DOTFILES_DIR" diff --cached --quiet; then
    echo "✅ No changes to commit."
else
    LAST_COMMIT_MSG=$(git -C "$DOTFILES_DIR" log -1 --pretty=%s)
    CHANGED_FILES=$(git -C "$DOTFILES_DIR" diff --cached --name-only | sed 's/^/- /')

    if [[ "$LAST_COMMIT_MSG" =~ ^🔄\ Automated\ push\ of\ dotfiles ]]; then
        if [ "$DRY_RUN" = true ]; then
            echo -e "\n🟡 [Dry Run] Would amend last commit."
        else
            git -C "$DOTFILES_DIR" commit --amend -m "🔄 Automated push of dotfiles\n\nChanged files:\n$CHANGED_FILES"
        fi
    else
        if [ "$DRY_RUN" = true ]; then
            echo -e "\n🟡 [Dry Run] Would create a new commit."
        else
            git -C "$DOTFILES_DIR" commit -m "🔄 Automated push of dotfiles\n\nChanged files:\n$CHANGED_FILES"
        fi
    fi

    if [ "$DRY_RUN" = true ]; then
        echo -e "\n🟡 [Dry Run] Would push changes to remote."
    else
        git -C "$DOTFILES_DIR" push origin main
    fi
fi

# Move to a new line after progress bar completion
echo ""
echo "🎉 Dotfiles push complete."
if [ "$DRY_RUN" = true ]; then
    echo "🟡 Dry-run mode: No changes were actually made."
fi

