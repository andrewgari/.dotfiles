# This file adds Nerd Fonts to your NixOS configuration
# To apply these changes, you'll need to either:
#   1. Copy the relevant lines to your /etc/nixos/configuration.nix (requires sudo)
#   2. Import this file in your configuration.nix

{ config, pkgs, ... }:

{
  # Install Nerd Fonts
  fonts = {
    packages = with pkgs; [
      (nerdfonts.override { 
        fonts = [ 
          "JetBrainsMono" 
          "FiraCode" 
          "Meslo" 
          "Hack"
          "CascadiaCode"
          "SourceCodePro"
        ]; 
      })
    ];
    fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" "JetBrainsMono" ];
    };
  };

  # You can also add these fonts to your Home Manager configuration:
  # home-manager.users.andrewgari = {
  #   home.packages = with pkgs; [
  #     (nerdfonts.override { 
  #       fonts = [ 
  #         "JetBrainsMono" 
  #         "FiraCode" 
  #         "Meslo" 
  #         "Hack"
  #         "CascadiaCode"
  #         "SourceCodePro"
  #       ]; 
  #     })
  #   ];
  # };
}