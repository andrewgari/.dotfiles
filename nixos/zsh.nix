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
      ignoreSpace = true;
      expireDuplicatesFirst = true;
    };
    
    # Shell options
    setOptions = [
      "HIST_IGNORE_DUPS"
      "HIST_IGNORE_ALL_DUPS"
      "HIST_REDUCE_BLANKS"
      "SHARE_HISTORY"
      "APPEND_HISTORY"
      "AUTO_CD"
      "AUTO_PUSHD"
      "PUSHD_IGNORE_DUPS"
      "PUSHD_SILENT"
    ];
    
    # Editor and environment settings
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      DISPLAY = ":0";
      SOFTWARE_UPDATE_AVAILABLE = "📦 ";
    };
    
    # Path management
    initExtraBeforeCompInit = ''
      # Path management - remove duplicate entries
      typeset -U PATH
      export PATH=~/.npm-global/bin:$PATH
      export PATH=~/.local/bin:$PATH
    '';
    
    # Completion settings
    enableCompletion = true;
    completionInit = ''
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
    '';
    
    # Default keymap
    defaultKeymap = "emacs";
    
    # Additional init
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
    
    # Syntax highlighting
    syntaxHighlighting = {
      enable = true;
      highlighters = [ "main" "brackets" "pattern" "cursor" "root" "line" ];
      styles = {
        "alias" = "fg=magenta,bold";
        "function" = "fg=blue,bold";
        "command" = "fg=green,bold";
        "path" = "fg=cyan,underline";
      };
    };
    
    # Auto suggestions
    autosuggestion = {
      enable = true;
      strategy = [ "history" "completion" ];
      highlightStyle = "fg=244";
    };
    
    # Use zplug for plugin management
    zplug = {
      enable = true;
      plugins = [
        { name = "zsh-users/zsh-autosuggestions"; }
        { name = "zsh-users/zsh-syntax-highlighting"; }
        { name = "zdharma-continuum/fast-syntax-highlighting"; tags = [ "as:plugin" "depth:1" ]; }
        { name = "zsh-users/zsh-completions"; }
      ];
    };
  };
  
  # direnv integration
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
  
  # Starship prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✗](bold red)";
      };
      directory = {
        truncation_length = 3;
        truncation_symbol = "…/";
      };
      git_branch = {
        format = "[$symbol$branch]($style) ";
        symbol = "🌱 ";
      };
    };
  };
  
  # Systemd service for script permissions
  systemd.user.services.script-permissions = {
    Unit = {
      Description = "Make scripts executable";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.findutils}/bin/find $HOME/.scripts -type f -not -perm -u+x -exec ${pkgs.coreutils}/bin/chmod +x {} \\;";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}