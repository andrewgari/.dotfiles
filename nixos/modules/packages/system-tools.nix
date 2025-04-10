# System utilities and CLI tools
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # System management
    home-manager
    
    # Shell utilities
    bat
    eza
    fd
    duf
    unzip
    zoxide
    wget
    curl
    ripgrep
    rsync
    htop
    btop
    thefuck
    # dotfiles - removed as it's not a standard package
    
    # Terminal emulators and tools
    # (Also configured in terminals module, but included here to ensure availability)
    kitty
    alacritty
    wezterm
    starship
    fastfetch
    
    # Shell
    # (Also configured in shell module, but included here to ensure availability)
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
  ];
}