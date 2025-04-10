# Terminal configurations module
{ ... }:

{
  imports = [
    ./alacritty.nix
    ./kitty.nix 
    ./wezterm.nix
  ];
}