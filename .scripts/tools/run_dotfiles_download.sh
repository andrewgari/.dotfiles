#!/bin/bash

# Live script to update local dotfiles from the remote repository
DOTFILES_REPO=git@github.com:andrewgari/.dotfiles
DOTFILES_DIR=~/Repos/dotfiles
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

echo "🔄 Copying latest files from repo to home directory..."

# Loop through each file and sync it
for file in "${file_list[@]}"; do
    ((current_file++))
    progress_bar "$total_files" "$current_file" "$file"

    dest="$HOME/$file"
    repo_file="$DOTFILES_DIR/$file"

    if [ -f "$repo_file" ]; then
        mkdir -p "$(dirname "$dest")"

        if [ "$DRY_RUN" = true ]; then
            echo -e "\n🟡 [Dry Run] Would update: $repo_file -> $dest"
        else
            rsync -a "$repo_file" "$dest" > /dev/null
        fi
    else
        echo -e "\n⚠️ File $repo_file does not exist, skipping update."
    fi
done

# Move to new line after progress bar completion
echo ""
echo "🎉 Dotfiles update complete."
if [ "$DRY_RUN" = true ]; then
    echo "🟡 Dry-run mode: No changes were actually made."
fi

