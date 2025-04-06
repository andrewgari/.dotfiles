# Basic configuration file

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Core system packages
  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    vim
    firefox
    htop
  ];

  # Define a user account
  users.users.andrewgari = {
    isNormalUser = true;
    description = "Andrew Gari";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # System version
  system.stateVersion = "24.11";
}
