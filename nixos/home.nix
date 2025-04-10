{ config, pkgs, lib, unstable, ... }:

{
  # Home Manager needs a bit of info about you and the paths it should manage
  home.username = "andrewgari";  # Replace with your username
  home.homeDirectory = "/home/andrewgari";  # Replace with your home directory
  nixpkgs.config.allowUnfree = true;
  
  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Packages to install
  home.packages = with pkgs; [
    steam
    lutris

    unstable.code-cursor
    unstable.windsurf
    unstable.claude-code

    _1password-cli
    _1password-gui
    nextcloud-client
    youtube-music
    vencord
    obs-studio
    lazydocker
    # Fonts
    jetbrains-mono
#    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
    noto-fonts-emoji
  ];

  # ZSH Configuration
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    history = {
      size = 100000;
      save = 100000;
      path = "${config.home.homeDirectory}/.zsh_history";
      ignoreDups = true;
      extended = true;
      share = true;
    };
    
    shellAliases = {
      # System utilities
      zshrc = "\${EDITOR:-nvim} ~/.zshrc && source ~/.zshrc";
      aliases = "\${EDITOR:-nvim} ~/.zsh-aliases && source ~/.zshrc";
      vimrc = "\${EDITOR:-nvim} ~/.config/nvim/init.lua";
      
      # Directory navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      "~" = "cd ~";
      docs = "cd ~/Documents";
      dl = "cd ~/Downloads";
      repos = "cd ~/Repos";
      starbunk = "cd ~/Repos/starbunk-js";
      unraid = "cd /mnt/unraid";
      "-" = "cd -";
      
      # Git commands
      g = "git";
      gs = "git status -sb";
      ga = "git add";
      gaa = "git add --all";
      gc = "git commit -m";
      gp = "git push -u origin";
      gl = "git log --oneline --graph --decorate --all";
      gd = "git diff";
      gds = "git diff --staged";
      gco = "git switch";
      gcob = "git switch -c";
      gpull = "git pull origin";
      gf = "git fetch --all";
      grb = "git rebase";
      gm = "git merge";
      gre = "git restore";
      grs = "git restore --staged";
      gpf = "git push --force-with-lease";
      grh = "git reset --hard";
      gb = "git branch";
      gbl = "git branch -l";
      gbr = "git branch -r";
      gbd = "git branch -d";
      gcl = "git clone";
      gst = "git stash";
      gstp = "git stash pop";
      gundo = "git reset --soft HEAD~1";
      
      # Dotfiles
      dotgit = "git --git-dir=$HOME/Repos/dotfiles/.git --work-tree=$HOME/Repos/dotfiles";
      dotfiles = "cd ~/Repos/dotfiles/.scripts/tools";
      scripts = "cd ~/.scripts/tools";
      "dotfiles-status" = "dotgit status";
      "dotfiles-log" = "dotgit log --oneline --graph --decorate -n 10";
      "dotfiles-reset" = "dotgit reset --hard && dotgit clean -fd";
      
      # File operations
      trash = "mv --force -t ~/.local/share/Trash ";
      rm = "rm -i";
      cp = "cp -i";
      mv = "mv -i";
      mkdir = "mkdir -p";
      md = "mkdir -p";
      print = "echo";
      edit = "\${EDITOR:-nvim}";
      
      # Modern CLI tools
      ls = "exa --icons";
      ll = "exa -l --icons --group-directories-first";
      la = "exa -la --icons --group-directories-first";
      lt = "exa -lT --icons --git-ignore";
      lg = "exa -l --git --icons";
      lsd = "exa -D --icons";
      lt1 = "exa -lT --icons --level=1";
      lt2 = "exa -lT --icons --level=2";
      cat = "bat --style=plain";
      bathelp = "bat --plain --language=help";
      catp = "bat -p";
      grep = "rg";
      
      # Network commands
      myip = "curl ifconfig.me";
      localip = "hostname -I | awk '{print \$1}'";
      ips = "ip -c a";
      ports = "ss -tulanp";
      listening = "ss -ltn";
      connections = "ss -tn";
    };
    
    initExtra = ''
      # Environment variables
      export EDITOR=nvim
      export VISUAL=nvim
      export DISPLAY=:0
      export SOFTWARE_UPDATE_AVAILABLE='📦 '
      
      # Path management - remove duplicate entries
      typeset -U PATH
      export PATH=~/.npm-global/bin:$PATH
      export PATH=~/.local/bin:$PATH
      
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
      
      # ZSH functions
      # Extract any archive
      extract() {
        if [ -f $1 ] ; then
          case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
          esac
        else
          echo "'$1' is not a valid file"
        fi
      }
      
      # Create directory and enter it
      mkcd() {
        mkdir -p "$1" && cd "$1"
      }
      
      # Find directory and cd into it
      cdg() {
        local dir
        dir=$(find ''${1:-.} -type d -not -path "*/\.*" | fzf +m) && cd "$dir"
      }
      
      # Function to modify cd to list contents
      cd() {
        builtin cd "$@" && ls
      }
      
      # Docker shell
      dsh() {
        docker exec -it "$1" /bin/bash || docker exec -it "$1" /bin/sh
      }
      
      # Generate a strong password
      genpass() {
        local length=''${1:-20}
        openssl rand -base64 48 | cut -c1-$length
      }
      
      # Quick calculations
      calc() {
        echo "scale=2; $*" | bc -l
      }
      
      # Get IP addresses
      whatismyip() {
        echo "Public IP: $(curl -s ifconfig.me)"
        echo "Local IP: $(hostname -I | awk '{print $1}')"
      }
      
      # Serve directory
      serve() {
        local port=''${1:-8000}
        echo "Serving on http://localhost:$port"
        python3 -m http.server $port
      }
      
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
      
      # Run fastfetch if installed
      if command -v fastfetch &>/dev/null; then
          fastfetch
      fi
    '';
    
    plugins = [
      {
        name = "fast-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zdharma-continuum";
          repo = "fast-syntax-highlighting";
          rev = "v1.55";
          sha256 = "0h7f27gz586xxw7cc0wyiv3bx0x3qih2wwh05ad85bh2h834ar8d";
        };
      }
    ];
  };

  # Kitty Terminal Configuration
  programs.kitty = {
    enable = true;
    font = {
      name = "FiraCode Nerd Font";
      size = 12;
    };
    settings = {
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
      
      # Rendering
      adjust_line_height = "110%";
      adjust_column_width = "100%";
      disable_ligatures = "never";
      
      # Colors (Catppuccin Mocha)
      foreground = "#cdd6f4";
      background = "#1e1e2e";
      selection_foreground = "#1e1e2e";
      selection_background = "#f5e0dc";
      cursor = "#f38ba8";
      url_color = "#89b4fa";
      
      # Black
      color0 = "#45475a";
      color8 = "#585b70";
      
      # Red
      color1 = "#f38ba8";
      color9 = "#f38ba8";
      
      # Green
      color2 = "#a6e3a1";
      color10 = "#a6e3a1";
      
      # Yellow
      color3 = "#f9e2af";
      color11 = "#f9e2af";
      
      # Blue
      color4 = "#89b4fa";
      color12 = "#89b4fa";
      
      # Magenta
      color5 = "#cba6f7";
      color13 = "#cba6f7";
      
      # Cyan
      color6 = "#94e2d5";
      color14 = "#94e2d5";
      
      # White
      color7 = "#bac2de";
      color15 = "#a6adc8";
      
      # Scrollback
      scrollback_lines = 10000;
      wheel_scroll_multiplier = 5.0;
      enable_audio_bell = "no";
      
      # Window behavior
      window_padding_width = 8;
      confirm_os_window_close = 0;
      background_opacity = 0.95;
      
      # Shell settings
      shell = "zsh";
    };
    
    keybindings = {
      "ctrl+shift+t" = "new_tab";
      "ctrl+shift+w" = "close_tab";
      "ctrl+shift+left" = "previous_tab";
      "ctrl+shift+right" = "next_tab";
      "ctrl+shift+up" = "increase_font_size";
      "ctrl+shift+down" = "decrease_font_size";
      "ctrl+shift+r" = "launch --type=overlay btop";
      "ctrl+shift+f" = "launch --type=overlay ranger";
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";
    };
  };

  # Alacritty Terminal Configuration
  programs.alacritty = {
    enable = true;
    settings = {
      live_config_reload = true;
      
      window = {
        dynamic_padding = false;
        opacity = 0.5;
        startup_mode = "Windowed";
        dimensions = {
          columns = 100;
          lines = 85;
        };
        padding = {
          x = 0;
          y = 0;
        };
      };
      
      scrolling = {
        history = 10000;
        multiplier = 3;
      };
      
      font = {
        size = 14.0;
        normal = {
          family = "JetBrains Mono";
          style = "Medium";
        };
        bold = {
          family = "JetBrains Mono";
          style = "Bold";
        };
        italic = {
          family = "JetBrains Mono";
          style = "Light Italic";
        };
        offset = {
          x = 0;
          y = 0;
        };
        glyph_offset = {
          x = 0;
          y = 0;
        };
      };
      
      # Basic colors
      colors = {
        primary = {
          background = "0x1d1f21";
          foreground = "0xc5c8c6";
        };
        cursor = {
          text = "0x1d1f21";
          cursor = "0xc5c8c6";
        };
        normal = {
          black = "0x1d1f21";
          red = "0xcc6666";
          green = "0xb5bd68";
          yellow = "0xf0c674";
          blue = "0x81a2be";
          magenta = "0xb294bb";
          cyan = "0x8abeb7";
          white = "0xc5c8c6";
        };
        bright = {
          black = "0x969896";
          red = "0xde935f";
          green = "0x282a2e";
          yellow = "0x373b41";
          blue = "0xb4b7b4";
          magenta = "0xe0e0e0";
          cyan = "0xa3685a";
          white = "0xffffff";
        };
      };
      
      # Other settings
      cursor = {
        style = "Block";
        unfocused_hollow = true;
      };
      
      selection = {
        semantic_escape_chars = ",│`|:\"' ()[]{}<>";
        save_to_clipboard = false;
      };
      
      mouse = {
        hide_when_typing = true;
      };
    };
  };

  # WezTerm Configuration
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require("wezterm")
      local config = wezterm.config_builder()

      config.colors = {
        foreground = "#d0d0d0",
        background = "#1c2438",
        cursor_bg = "#c6c8d1",
        cursor_fg = "#1c2438",
        selection_bg = "#3d4b6b",
        selection_fg = "#c6c8d1",
        ansi = {
          "#1c2438",
          "#ff6b6b",
          "#5ec4b6",
          "#f9d76c",
          "#84a0ef",
          "#c39ac9",
          "#89dceb",
          "#c6c8d1",
        },
        brights = {
          "#394b70",
          "#ff8080",
          "#6fe0d2",
          "#ffe084",
          "#9bb2ff",
          "#dcb3e5",
          "#9aecf7",
          "#e4e6ef",
        },
      }

      -- URL handling
      config.hyperlink_rules = {
        {
          regex = "\\b\\w+://(?:[\\w.-]+)[:\\w/@?&=%+#-]*",
          format = "$0",
        },
      }

      config.keys = {
        -- Splits
        { key = "p", mods = "ALT", action = wezterm.action.SplitPane({ direction = "Right" }) },
        { key = "o", mods = "ALT", action = wezterm.action.SplitPane({ direction = "Down" }) },
        { key = "d", mods = "ALT", action = wezterm.action.SplitPane({ direction = "Down" }) },
        { key = "d", mods = "ALT|SHIFT", action = wezterm.action.SplitPane({ direction = "Right" }) },

        -- Navigation
        { key = "LeftArrow", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Left") },
        { key = "RightArrow", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Right") },
        { key = "UpArrow", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Up") },
        { key = "DownArrow", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Down") },

        -- Resize
        { key = "LeftArrow", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Left", 5 }) },
        { key = "RightArrow", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Right", 5 }) },
        { key = "UpArrow", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Up", 5 }) },
        { key = "DownArrow", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Down", 5 }) },

        -- Tabs
        { key = "t", mods = "ALT", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
        { key = "[", mods = "ALT", action = wezterm.action.ActivateTabRelative(-1) },
        { key = "]", mods = "ALT", action = wezterm.action.ActivateTabRelative(1) },
        { key = "1", mods = "ALT", action = wezterm.action.ActivateTab(0) },
        { key = "2", mods = "ALT", action = wezterm.action.ActivateTab(1) },
        { key = "3", mods = "ALT", action = wezterm.action.ActivateTab(2) },
        { key = "4", mods = "ALT", action = wezterm.action.ActivateTab(3) },
        { key = "5", mods = "ALT", action = wezterm.action.ActivateTab(4) },

        -- Window
        { key = "w", mods = "ALT", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
        { key = "f", mods = "ALT", action = wezterm.action.ToggleFullScreen },
        { key = "=", mods = "ALT", action = wezterm.action.IncreaseFontSize },
        { key = "-", mods = "ALT", action = wezterm.action.DecreaseFontSize },
        { key = "0", mods = "ALT", action = wezterm.action.ResetFontSize },

        -- Advanced features
        { key = "z", mods = "ALT", action = wezterm.action.TogglePaneZoomState },
        { key = "Space", mods = "ALT", action = wezterm.action.QuickSelect },
        { key = "f", mods = "ALT|SHIFT", action = wezterm.action.Search({ CaseSensitiveString = "" }) },
        { key = "r", mods = "ALT", action = wezterm.action.RotatePanes("Clockwise") },
        { key = "m", mods = "ALT", action = wezterm.action.PaneSelect({ mode = "SwapWithActive" }) },
        { key = "q", mods = "ALT", action = wezterm.action.CloseCurrentPane({ confirm = false }) },
      }

      -- Font configuration
      config.font = wezterm.font_with_fallback({
        "JetBrains Mono",
        "FiraCodeNerdFontsMono",
        "Noto Color Emoji",
      })
      config.font_size = 12
      config.line_height = 1.2
      config.harfbuzz_features = { "calt=1", "liga=1" }

      -- Window appearance
      config.window_background_opacity = 0.95
      config.window_decorations = "TITLE | RESIZE"
      config.window_padding = { left = 2, right = 2, top = 0, bottom = 0 }

      -- Tab bar
      config.use_fancy_tab_bar = true
      config.tab_bar_at_bottom = true
      config.hide_tab_bar_if_only_one_tab = true
      config.window_close_confirmation = "AlwaysPrompt"

      -- Features
      config.scrollback_lines = 10000
      config.enable_scroll_bar = true
      config.enable_wayland = true

      return config
    '';
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    
    settings = {
      # Custom format
      format = "$env_var$username$hostname$directory$git_branch$git_status$cmd_duration$character";
      
      character = {
        success_symbol = "[⚡](bold green)";
        error_symbol = "[💥](bold red)";
      };
      
      "env_var.OS_ICON" = {
        variable = "STARSHIP_OS";
        default = "";
        format = "[$env_value]($style) ";
        style = "bold blue";
      };
      
      hostname = {
        ssh_only = false;
        format = "[$hostname]($style) ";
        style = "bold yellow";
      };
      
      directory = {
        truncation_length = 3;
        truncation_symbol = "…/";
        style = "bold cyan";
        format = "[ $path]($style) ";
        read_only = " 🔒";
        read_only_style = "red";
      };
      
      git_branch = {
        symbol = " ";
        format = "[$symbol$branch]($style) ";
        style = "bold purple";
      };
      
      git_status = {
        conflicted = "󰞇 ";
        ahead = "⇡\${count} ";
        behind = "⇣\${count} ";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count} ";
        untracked = "?\${count} ";
        stashed = "󰏖 ";
        modified = "!\${count} ";
        staged = "+\${count} ";
        renamed = "»\${count} ";
        deleted = "✘\${count} ";
        style = "bold red";
        format = "([$all_status$ahead_behind]($style) )";
      };
      
      cmd_duration = {
        min_time = 500;
        format = "took [$duration](bold yellow)";
      };
    };
  };

  # Zoxide integration
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Fzf integration
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = ["--height 40% --layout=reverse --border"];
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You should not change this value, even if you update Home Manager.
  # If you do want to update the value, then make sure to first
  # check the Home Manager release notes.
  home.stateVersion = "24.11";
}
