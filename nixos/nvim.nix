{ config, pkgs, lib, ... }:

{
  # Enable ZSH
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
    
    # Default editor
    shellInit = ''
      export EDITOR=nvim
      export VISUAL=nvim
      export DISPLAY=:0
    '';
    
    # Shell options
    setOptions = [
      "HIST_IGNORE_DUPS"
      "HIST_IGNORE_ALL_DUPS"
      "HIST_REDUCE_BLANKS"
      "SHARE_HISTORY"
      "APPEND_HISTORY"
    ];
    
    # Key bindings - these will need to be in initExtra
    initExtra = ''
      # Key bindings
      bindkey '^[[A' history-search-backward  # Up Arrow for history search
      bindkey '^[[B' history-search-forward   # Down Arrow for history search
      bindkey '^[[1;5C' forward-word          # Ctrl + →
      bindkey '^[[1;5D' backward-word         # Ctrl + ←
      bindkey '^H' backward-kill-word         # Ctrl + Backspace
      bindkey '^U' backward-kill-line         # Ctrl + U
      bindkey '^L' clear-screen               # Ctrl + L
      bindkey '^[q' kill-whole-line           # Alt + Q
      bindkey -M viins '^[[Z' reverse-menu-complete  # Shift + Tab
      bindkey '^A' beginning-of-line          # Ctrl + A
      bindkey '^E' end-of-line                # Ctrl + E
      bindkey '^K' kill-line                  # Ctrl + K
      bindkey '^R' history-incremental-search-backward  # Ctrl + R
      
      # Path management - remove duplicate entries
      typeset -U PATH
      export PATH=~/.npm-global/bin:$PATH
      export PATH=~/.local/bin:$PATH
      
      # Load machine-specific settings if present
      if [ -f ~/.zshrc.local ]; then
          source ~/.zshrc.local
      fi
      
      if [ -f ~/.zsh-aliases.local ]; then
          source ~/.zsh-aliases.local
      fi
      
      # Scripts directory permissions
      if [ -d "$HOME/.scripts" ]; then
          find "$HOME/.scripts" -type f -not -perm -u+x -exec chmod +x {} \;
      fi
      
      # Software update notification
      export SOFTWARE_UPDATE_AVAILABLE='📦 '
    '';
    
    # Aliases - converting your extensive alias list
    shellAliases = {
      # System utilities
      zshrc = "\${EDITOR:-nvim} ~/.zshrc && source ~/.zshrc";
      aliases = "\${EDITOR:-nvim} ~/.zsh-aliases && source ~/.zshrc";
      vimrc = "\${EDITOR:-nvim} ~/.config/nvim/init.lua";
      
      # Navigation
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
      
      # Systemd commands
      status = "systemctl status";
      start = "systemctl start";
      enable = "systemctl enable";
      disable = "systemctl disable";
      stop = "systemctl stop";
      restart = "systemctl daemon-reload";
      
      # File operations
      trash = "mv --force -t ~/.local/share/Trash ";
      rm = "rm -i";
      cp = "cp -i";
      mv = "mv -i";
      mkdir = "mkdir -p";
      md = "mkdir -p";
      print = "echo";
      edit = "\${EDITOR:-nvim}";
      
      # SSH shortcuts
      sshpc = "ssh andrewgari@192.168.50.2";
      sshwork = "ssh andrewgari@192.168.50.11";
      ssh_copy_id = "ssh-copy-id -i ~/.ssh/id_rsa.pub";
      
      # Network commands
      myip = "curl ifconfig.me";
      localip = "hostname -I | awk '{print \$1}'";
      ips = "ip -c a";
      ports = "ss -tulanp";
      listening = "ss -ltn";
      connections = "ss -tn";
      
      # Docker/Podman
      dps = "docker ps";
      dpa = "docker ps -a";
      drm = "docker rm";
      drmi = "docker rmi";
      dstop = "docker stop";
      drestart = "docker restart";
      dlogs = "docker logs";
      dexec = "docker exec -it";
      dimg = "docker images";
      dcup = "docker-compose up -d";
      dcdown = "docker-compose down";
      dcps = "docker-compose ps";
      dclogs = "docker-compose logs -f";
      dcrestart = "docker-compose restart";
      
      # And many more of your aliases...
      # (I've included a subset for brevity)
    };
    
    # Plugin management
    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.7.0";  # Check for the latest version
          sha256 = "1g3pij5qn2j7v7jjac2a63lxd97mcsgw6xq6k5p7835q9fjiid98";  # You'll need to update this hash
        };
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.7.1";  # Check for the latest version
          sha256 = "0b53vjjfsk322vpblwdj4vjq5vgmkr7jvzgocc3aiq1xkqc5jld7";  # You'll need to update this hash
        };
      }
      {
        name = "fast-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zdharma-continuum";
          repo = "fast-syntax-highlighting";
          rev = "v1.55";  # Check for the latest version
          sha256 = "0h7f27gz586xxw7cc0wyiv3bx0x3qih2wwh05ad85bh2h834ar8d";  # You'll need to update this hash
        };
      }
      # Add more of your plugins as needed
    ];
  };
  
  # Install your commonly used packages
  environment.systemPackages = with pkgs; [
    # Basics
    git
    curl
    wget
    ripgrep  # rg
    fd  # fd-find
    exa  # ls replacement
    bat  # cat replacement
    zoxide  # z command
    fzf  # fuzzy finder
    
    # Development
    neovim
    python3
    nodejs
    
    # System tools
    htop
    btop
    duf  # df replacement
    
    # Additional tools from your aliases
    fastfetch
    starship  # For your prompt
    
    # Add more packages as needed
  ];
  
  # Enable Starship prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
  
  # Setup Zoxide
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
