# modules/zsh/default.nix
{ config, pkgs, lib, ... }:

{
  imports = [
    ./zsh-aliases.nix
  ];

  programs.zsh = {
    enable = true;
    
    # History settings
    history = {
      size = 100000;
      save = 100000;
      path = "$HOME/.zsh_history";
      ignoreDups = true;
      extended = true;
      share = true;
    };
    
    # Shell options
    setOptions = [
      "HIST_IGNORE_DUPS"
      "HIST_IGNORE_ALL_DUPS"
      "HIST_REDUCE_BLANKS"
      "SHARE_HISTORY"
      "APPEND_HISTORY"
    ];
    
    # Editor settings
    shellInit = ''
      export EDITOR=nvim
      export VISUAL=nvim
      export DISPLAY=:0
      export SOFTWARE_UPDATE_AVAILABLE='📦 '
      
      # Path management - remove duplicate entries
      typeset -U PATH
      export PATH=~/.npm-global/bin:$PATH
      export PATH=~/.local/bin:$PATH
      
      # Scripts directory permissions
      if [ -d "$HOME/.scripts" ]; then
          find "$HOME/.scripts" -type f -not -perm -u+x -exec chmod +x {} \;
      fi
    '';
    
    # Key bindings 
    initExtra = ''
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
      
      # Load machine-specific settings if present
      if [ -f ~/.zshrc.local ]; then
          source ~/.zshrc.local
      fi
      
      if [ -f ~/.zsh-aliases.local ]; then
          source ~/.zsh-aliases.local
      fi
    '';
  };

  # Install the plugins you use
  programs.zsh.plugins = [
    {
      name = "zsh-autosuggestions";
      src = pkgs.fetchFromGitHub {
        owner = "zsh-users";
        repo = "zsh-autosuggestions";
        rev = "v0.7.0";
        sha256 = lib.fakeSha256; # Replace with actual hash when building
      };
    }
    {
      name = "zsh-syntax-highlighting";
      src = pkgs.fetchFromGitHub {
        owner = "zsh-users";
        repo = "zsh-syntax-highlighting";
        rev = "0.7.1";
        sha256 = lib.fakeSha256; # Replace with actual hash when building
      };
    }
    {
      name = "fast-syntax-highlighting";
      src = pkgs.fetchFromGitHub {
        owner = "zdharma-continuum";
        repo = "fast-syntax-highlighting";
        rev = "v1.55";
        sha256 = lib.fakeSha256; # Replace with actual hash when building
      };
    }
  ];
}
