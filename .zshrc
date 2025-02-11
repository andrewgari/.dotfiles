

# -----------------------------
# Aliases
# -----------------------------

# Source aliases from ~/.aliases if it exists
[ -f ~/.aliases ] && source ~/.aliases

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

bindkey '^[[A' history-substring-search-up   # Up arrow for fuzzy search
bindkey '^[[B' history-substring-search-down # Down arrow for fuzzy search

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
zstyle
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
