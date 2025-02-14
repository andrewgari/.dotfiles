# ~/.zshrc - Portable Zsh Configuration

# -----------------------------
# Dependency Auto-Installer
# -----------------------------

install_if_missing() {
    local package=$1
    local install_cmd=$2
    if ! command -v "$package" &>/dev/null; then
        echo "⚡ Installing missing dependency: $package..."
        eval "$install_cmd"
    fi
}

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

# Install Common CLI Tools (if system package manager is detected)
if [[ -n "$PKG_INSTALL_CMD" ]]; then
    install_if_missing "zoxide" "$PKG_INSTALL_CMD zoxide"
    install_if_missing "fzf" "$PKG_INSTALL_CMD fzf"
    install_if_missing "bat" "$PKG_INSTALL_CMD bat"
    install_if_missing "exa" "$PKG_INSTALL_CMD exa"
    install_if_missing "fastfetch" "$PKG_INSTALL_CMD fastfetch"
    install_if_missing "htop" "$PKG_INSTALL_CMD htop"
fi


# -----------------------------
# Zsh Plugin Manager (zinit)
# -----------------------------


# -----------------------------
# Machine-Specific Configuration
# -----------------------------

# Load machine-specific settings if present
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi

# -----------------------------
# Aliases
# -----------------------------

# Load global aliases (shared across systems)
if [ -f ~/.aliases ]; then
    source ~/.aliases
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
#bindkey '^[[A' history-substring-search-up
#bindkey '^[[B' history-substring-search-down

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

