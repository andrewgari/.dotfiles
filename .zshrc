# ~/.zshrc - Portable Zsh Configuration
# Add both variables to be thorough
export EDITOR=nvim
export VISUAL=nvim

# Start ssh-agent if not already running
if [ -z "$SSH_AUTH_SOCK" ]; then
   # Check if ssh-agent is already running
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/github_rsa
fi

# ---------
# Detect OS & Package Manager
if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
        fedora) PKG_INSTALL_CMD="sudo dnf install -y" ;;
        arch) PKG_INSTALL_CMD="sudo pacman -S --noconfirm" ;;
        ubuntu|debian) PKG_INSTALL_CMD="sudo apt install -y" ;;
        *) PKG_INSTALL_CMD="" ;;  # Unsupported distro
    esac
elif [[ "$OSTYPE" == "darwin"* ]]; then
    if ! command -v brew &>/dev/null; then
        echo "⚡ Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    PKG_INSTALL_CMD="brew install"
fi

# Install Zinit (Zsh Plugin Manager)
if [[ ! -f "$HOME/.zinit/bin/zinit.zsh" ]]; then
    echo "⚡ Installing Zinit (Zsh plugin manager)..."
    mkdir -p "$HOME/.zinit" && git clone https://github.com/zdharma-continuum/zinit.git "$HOME/.zinit/bin"
fi
source "$HOME/.zinit/bin/zinit.zsh"

# -----------------------------
# Machine-Specific Configuration
# -----------------------------

# Load machine-specific settings if present
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi

if [[ -f ~/.netrc ]]; then
# export GITHUB_TOKEN=$(awk '/github.com/ {getline; print $2}' ~/.netrc)
fi


# -----------------------------
# Aliases
# -----------------------------

# Load global aliases (shared across systems)
if [ -f ~/.zsh-aliases ]; then
    source ~/.zsh-aliases
fi

if [ -f ~/.zsh-aliases.local ]; then
    source ~/.zsh-aliases.local
fi

export SOFTWARE_UPDATE_AVAILABLE='📦 '

# -----------------------------
# History Settings
# -----------------------------

HISTSIZE=100000
SAVEHIST=100000
HISTFILE="$HOME/.zsh_history"

setopt HIST_IGNORE_DUPS     # Ignore duplicate commands
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS   # Remove unnecessary blanks
setopt SHARE_HISTORY        # Share command history across terminals
setopt APPEND_HISTORY       # Append to history file instead of overwriting

# -----------------------------
# Key Bindings (History Search)
# -----------------------------

# History search with up/down arrows
bindkey '^[[A' history-search-backward  # Up Arrow for history search
bindkey '^[[B' history-search-forward   # Down Arrow for history search

# Word navigation
bindkey '^[[1;5C' forward-word          # Ctrl + →
bindkey '^[[1;5D' backward-word         # Ctrl + ←
bindkey '^H' backward-kill-word         # Ctrl + Backspace
bindkey '^U' backward-kill-line         # Ctrl + U
bindkey '^L' clear-screen               # Ctrl + L
bindkey '^[q' kill-whole-line           # Alt + Q
bindkey -M viins '^[[Z' reverse-menu-complete  # Shift + Tab

# Add Emacs-like bindings
bindkey '^A' beginning-of-line          # Ctrl + A
bindkey '^E' end-of-line                # Ctrl + E
bindkey '^K' kill-line                  # Ctrl + K
bindkey '^R' history-incremental-search-backward  # Ctrl + R

# -----------------------------
# Prompt Enhancements
# -----------------------------

# Use Starship if installed
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

# -----------------------------
# Completion System
# -----------------------------

autoload -Uz compinit && compinit

# Enable additional completion scripts if installed
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive matching
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # Colored completion items
zstyle ':completion:*' special-dirs true # Complete special directories like .. and ~

# -----------------------------
# Plugins (Managed via zinit)
# -----------------------------

# Syntax highlighting
zinit light zsh-users/zsh-syntax-highlighting

# Autosuggestions (gray text suggesting previous commands)
zinit light zsh-users/zsh-autosuggestions

# Fast syntax highlighting (already loaded below)

# Fuzzy finder for command history and completions
zinit light Aloxaf/fzf-tab

# Colored suggestions, e.g., `git` commands
zinit light zdharma-continuum/history-search-multi-word

# Enhance directory navigation (`..` auto-expands)
zinit light rupa/z

# Git plugin with improved aliases and completion
zinit ice wait lucid atload"alias gst='git status'"
zinit light zdharma-continuum/fast-syntax-highlighting

# Adds extra completions for common tools
zinit light zsh-users/zsh-completions

# -----------------------------
# Fuzzy Finder (`fzf`)
# -----------------------------

# Use `fzf` if installed for interactive completion
if command -v fzf &>/dev/null; then
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
    zinit light junegunn/fzf
    zinit light junegunn/fzf-git.sh
fi

# -----------------------------
# Run Fastfetch (If Installed)
# -----------------------------

if command -v fastfetch &>/dev/null; then
    fastfetch
fi

if [ -d "$HOME/.scripts" ]; then
    find "$HOME/.scripts" -type f -not -perm -u+x -exec chmod +x {} \;
fi

# These are already loaded via zinit plugins above
# source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
# source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# source ~/.zinit/bin/zinit.zsh (already sourced at the top)

# Path management - remove duplicate entries
typeset -U PATH
export PATH=~/.npm-global/bin:$PATH
export PATH=~/.local/bin:$PATH
export PATH=$PATH:/home/andrewgari/.cargo/bin

# Ensure we're not using fd as a replacement for find
unalias find 2>/dev/null
export DISPLAY=:0

if [ -e /home/andrewgari/.nix-profile/etc/profile.d/nix.sh ]; then . /home/andrewgari/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
