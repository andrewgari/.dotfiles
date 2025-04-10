# Browser packages
{ config, pkgs, ... }:

{
  programs.firefox.enable = true;
  
  environment.systemPackages = with pkgs; [
    floorp
  ];
}