#!/bin/zsh

# Configuration
DOTFILES_REPO=git@github.com:andrewgari/.dotfiles
DOTFILES_DIR=~/Repos/dotfiles
SCRIPTS_DIR="$HOME/.scripts"  # Directory to always sync
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

# Ensure the dotfiles repo exists
if [ ! -d "$DOTFILES_DIR/.git" ]; then
    echo "📥 Cloning dotfiles repository..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
    cd "$DOTFILES_DIR" || exit

    # Stash changes before pulling (only if there are unstaged modifications)
    if ! git diff --quiet || ! git diff --cached --quiet; then
        git stash push -m "Auto-stash before pull ($(date +'%Y-%m-%d %H:%M:%S'))" > /dev/null
    fi

    git pull --rebase > /dev/null

    # Restore stashed changes if there are any
    if git stash list | grep -q "Auto-stash before pull"; then
        git stash apply > /dev/null || { echo "⚠️ Merge conflicts detected, resolve manually!"; exit 1; }
        git stash drop > /dev/null
    fi
fi

# Get file count for progress bar
file_list=($(git -C "$DOTFILES_DIR" ls-files -z | tr '\0' '\n'))
total_files=${#file_list[@]}
current_file=0

# Process tracked files
for file in "${file_list[@]}"; do
    home_file="$HOME/$file"
    repo_file="$DOTFILES_DIR/$file"

    ((current_file++))
    progress_bar "$total_files" "$current_file" "$file"

    if [ -f "$home_file" ] && ! diff -q "$home_file" "$repo_file" >/dev/null 2>&1; then
        if [ "$DRY_RUN" = true ]; then
            echo -e "\n🟡 [Dry Run] Would update: $file"
        else
            rsync -avu "$home_file" "$repo_file" > /dev/null
            git -C "$DOTFILES_DIR" add "$file"
        fi
    fi
done

# Sync .scripts directory
script_files=($(find "$SCRIPTS_DIR" -type f))
total_scripts=${#script_files[@]}
current_script=0

for script in "${script_files[@]}"; do
    repo_script="$DOTFILES_DIR/.scripts/${script#$SCRIPTS_DIR/}"

    ((current_script++))
    progress_bar "$total_scripts" "$current_script" "$script"

    if [ "$DRY_RUN" = true ]; then
        echo -e "\n🟡 [Dry Run] Would sync: $script"
    else
        rsync -avu "$script" "$repo_script" > /dev/null
        git -C "$DOTFILES_DIR" add "$repo_script"
    fi
done

# Remove stale .scripts files
repo_scripts=($(git -C "$DOTFILES_DIR" ls-files ".scripts" -z | tr '\0' '\n'))
total_repo_scripts=${#repo_scripts[@]}
current_repo_script=0

for repo_file in "${repo_scripts[@]}"; do
    local_file="$SCRIPTS_DIR/${repo_file#".scripts/"}"

    ((current_repo_script++))
    progress_bar "$total_repo_scripts" "$current_repo_script" "$repo_file"

    if [ ! -e "$local_file" ]; then
        if [ "$DRY_RUN" = true ]; then
            echo -e "\n🟡 [Dry Run] Would remove: $repo_file"
        else
            git -C "$DOTFILES_DIR" rm --cached "$repo_file" > /dev/null
            rm -f "$DOTFILES_DIR/$repo_file"
        fi
    fi
done

# Move to new line after progress bar completion
echo ""

echo "✅ Dotfiles sync complete. Staged new and updated files, removed stale ones, but did not commit."
if [ "$DRY_RUN" = true ]; then
    echo "🟡 Dry-run mode: No changes were actually made."
fi

