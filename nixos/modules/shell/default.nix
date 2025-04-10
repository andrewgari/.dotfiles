# Shell configurations module
{ ... }:

{
  imports = [
    ./zsh.nix
    ./zsh-aliases.nix
    ./zsh-functions.nix
    ./starship.nix
  ];
}