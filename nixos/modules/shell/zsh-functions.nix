# modules/shell/zsh-functions.nix
{ config, pkgs, lib, ... }:

{
  # ZSH utility functions
  programs.zsh = {
    interactiveShellInit = ''
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
      
      # Jump to directories quickly with zoxide
      j() {
        [ $# -gt 0 ] || return
        cd "$(zoxide query "$@")" || return
      }
      
      # Git summary
      git-summary() {
        git rev-parse --is-inside-work-tree &>/dev/null || { echo "Not a git repository!"; return 1; }
        echo "Branch: $(git branch --show-current)"
        echo "Status:"
        git status -s
        echo "Recent commits:"
        git log --oneline -n 5
      }
      
      # Docker prune
      dprune() {
        echo "Pruning containers, networks, and images..."
        docker system prune -a -f
        echo "Pruning volumes..."
        docker volume prune -f
        echo "Docker system cleaned!"
      }
    '';
  };
}