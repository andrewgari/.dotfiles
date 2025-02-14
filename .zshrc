

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

#bindkey '^[[A' history-substring-search-up   # Up arrow for fuzzy search
#bindkey '^[[B' history-substring-search-down # Down arrow for fuzzy search
# Ensure zplug is installed
if [[ ! -d ~/.zplug ]]; then
    git clone https://github.com/zplug/zplug ~/.zplug
fi

# Load zplug
source ~/.zplug/init.zsh

# --- Plugins ---

# Prompt (Choose one)
zplug "Aloxaf/fzf-tab", from:github
zplug "zsh-users/zsh-autosuggestions", from:github
zplug "zsh-users/zsh-syntax-highlighting", from:github
zplug "mollifier/cd-gitroot", from:github
zplug "junegunn/fzf-bin", from:gh-r
zplug "zsh-users/zsh-history-substring-search", from:github
zplug "rupa/z", from:github
zplug "starship/starship", from:github, as:command
zplug "supercrabtree/k", from:github

# Essential utilities
zplug "zsh-users/zsh-history-substring-search" # Search history

# FZF Integration (Better history & file searching)

# Git Enhancements

# Extra Shell Utilities
zplug "djui/alias-tips" # Suggest alternatives for mistyped commands

# --- Load Plugins ---
zplug install --skip-if-exists
zplug load --verbose

# --- Extra Configurations ---

# FZF keybindings (better file search & command history)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Keybindings (CTRL+R for better history search)
bindkey '^R' history-substring-search-up
bindkey '^S' history-substring-search-down

# Ensure zplug stays updated
autoload -U zplug && zplug update



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
eval "$(zoxide init zsh)"

fastfetch
