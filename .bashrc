# -----------------------------
# Environment Variables
# -----------------------------


export SOFTWARE_UPDATE_AVAILABLE='📦 '

# -----------------------------
# Aliases
# -----------------------------

# Source aliases from ~/.aliases if it exists
if [ -f ~/.aliases ]; then
    source ~/.aliases
fi

# -----------------------------
# History Settings
# -----------------------------

HISTSIZE=100000
HISTFILESIZE=100000
HISTFILE="$HOME/.bash_history"

# Ignore duplicate commands and unnecessary blanks
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend         # Append to history instead of overwriting
shopt -s cmdhist            # Save multi-line commands as a single entry

# Share history across terminals (Bash does not have `SHARE_HISTORY` like Zsh)
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# -----------------------------
# Key Bindings (History Search)
# -----------------------------

# Enable arrow key history search (like Zsh’s fuzzy search)
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# -----------------------------
# Prompt Enhancements
# -----------------------------

# Use Starship if installed
if command -v starship &>/dev/null; then
    eval "$(starship init bash)"
fi

# -----------------------------
# Completion System
# -----------------------------

# Enable programmable completion
if [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
fi

# Syntax highlighting (Bash equivalent of Zsh's zsh-syntax-highlighting)
if [ -f /usr/share/bash-completion/bash_completion ]; then
    source /usr/share/bash-completion/bash_completion
fi

# Install and use `highlight` if available (alternative to Zsh syntax highlighting)
if command -v source-highlight &>/dev/null; then
    alias highlight='source-highlight --failsafe --style-file=esc.style -o STDOUT -i'
fi

fastfetch

export PATH=~/.npm-global/bin:$PATH
export PATH=~/.npm-global/bin:$PATH
export PATH=~/.npm-global/bin:$PATH
export PATH=~/.npm-global/bin:$PATH
