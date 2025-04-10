# modules/shell/zsh.nix
{ config, pkgs, lib, ... }:

{
  # Basic ZSH configuration
  environment.systemPackages = with pkgs; [
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
  ];
  
  # Enable ZSH system-wide
  programs.zsh.enable = true;
  
  # Set environment variables for ZSH users
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    DISPLAY = ":0";
    SOFTWARE_UPDATE_AVAILABLE = "📦 ";
  };
  
  # Common interactive shell initialization
  environment.interactiveShellInit = ''
    # Path management - remove duplicate entries
    if [ -n "$ZSH_VERSION" ]; then
      typeset -U PATH
    fi
    
    export PATH=~/.npm-global/bin:$PATH
    export PATH=~/.local/bin:$PATH
  '';
  
  # ZSH specific configuration
  programs.zsh = {
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    
    shellInit = ''
      # ZSH-specific initialization
      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_REDUCE_BLANKS
      setopt SHARE_HISTORY
      setopt APPEND_HISTORY
      
      HISTSIZE=100000
      SAVEHIST=100000
      HISTFILE=$HOME/.zsh_history
    '';
    
    interactiveShellInit = ''
      # Key bindings
      bindkey '^[[A' history-search-backward
      bindkey '^[[B' history-search-forward
      bindkey '^[[1;5C' forward-word
      bindkey '^[[1;5D' backward-word
      bindkey '^H' backward-kill-word
      bindkey '^U' backward-kill-line
      bindkey '^L' clear-screen
      bindkey '^[q' kill-whole-line
      bindkey -M viins '^[[Z' reverse-menu-complete
      bindkey '^A' beginning-of-line
      bindkey '^E' end-of-line
      bindkey '^K' kill-line
      bindkey '^R' history-incremental-search-backward
      
      # Scripts directory permissions
      if [ -d "$HOME/.scripts" ]; then
          find "$HOME/.scripts" -type f -not -perm -u+x -exec chmod +x {} \;
      fi
      
      # Load machine-specific settings if present
      if [ -f ~/.zshrc.local ]; then
          source ~/.zshrc.local
      fi
      
      if [ -f ~/.zsh-aliases.local ]; then
          source ~/.zsh-aliases.local
      fi
    '';
  };
}