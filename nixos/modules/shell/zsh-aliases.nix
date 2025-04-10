# Shell aliases for ZSH
{ config, pkgs, lib, ... }:

{
  programs.zsh.shellAliases = {
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
    ls = "eza --icons";
    ll = "eza -l --icons --group-directories-first";
    la = "eza -la --icons --group-directories-first";
    lt = "eza -lT --icons --git-ignore";
    lg = "eza -l --git --icons";
    lsd = "eza -D --icons";
    lt1 = "eza -lT --icons --level=1";
    lt2 = "eza -lT --icons --level=2";
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
}