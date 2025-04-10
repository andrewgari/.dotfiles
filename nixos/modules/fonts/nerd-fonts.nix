# Nerd Fonts module
{ config, lib, pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      (nerdfonts.override {
        fonts = [
          "JetBrainsMono"
          "FiraCode"
          "Hack"
          "SourceCodePro"
          "UbuntuMono"
        ];
      })
    ];
    fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
    };
  };
}