# ~/.zshrc - Portable Zsh Configuration

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
    export GITHUB_TOKEN=$(awk '/github.com/ {getline; print $2}' ~/.netrc)
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

# Uncomment these lines if you want to enable history substring search
bindkey '^[[A' history-search-backward  # Up Arrow for history search
bindkey '^[[B' history-search-forward   # Down Arrow for history search
bindkey '^[[1;5C' forward-word   # Ctrl + →
bindkey '^[[1;5D' backward-word  # Ctrl + ←
bindkey '^H' backward-kill-word  # Ctrl + Backspace
bindkey '^U' backward-kill-line
bindkey '^L' clear-screen
bindkey '^[q' kill-whole-line
bindkey -M viins '^[[Z' reverse-menu-complete

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

# -----------------------------
# Plugins (Managed via zinit)
# -----------------------------

# Syntax highlighting
zinit light zsh-users/zsh-syntax-highlighting

# Autosuggestions (gray text suggesting previous commands)
zinit light zsh-users/zsh-autosuggestions

# Fast syntax highlighting (alternative to above, pick one)
# zinit light zdharma-continuum/fast-syntax-highlighting

# Fuzzy finder for command history and completions
zinit light Aloxaf/fzf-tab

# Colored suggestions, e.g., `git` commands
zinit light zdharma-continuum/history-search-multi-word

# Enhance directory navigation (`..` auto-expands)
zinit light rupa/z

# Git plugin with improved aliases and completion
zinit ice wait lucid atload"alias gst='git status'" # Lazy-load with alias

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

if [[ "$OSTYPE" == "darwin"* ]]; then
    CRON_CMD="crontab -l 2>/dev/null"
else
    CRON_CMD="sudo crontab -l 2>/dev/null"
fi

if ! eval "$CRON_CMD" | grep -q "run_dotfiles_sync.sh"; then
    echo "🛠 Setting up cron jobs..."
    ~/.scripts/bootstrap/bootstrap_cron.sh
fi

# Ensure all scripts in ~/.scripts are executable
if [ -d "$HOME/.scripts" ]; then
    find "$HOME/.scripts" -type f -not -perm -u+x -exec chmod +x {} \;
fi

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zinit/bin/zinit.zsh
