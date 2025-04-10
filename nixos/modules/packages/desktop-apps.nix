# Desktop applications and utilities
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Media and entertainment
    bottles
    vlc
    vesktop
    gwenview
    
    # System utilities with GUI
    gparted
    gnome-tweaks
    gnome-extension-manager
    
    # File managers
    dolphin
    ranger
    
    # Windows compatibility
    wine
    winetricks
  ];
}