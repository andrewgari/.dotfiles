# Default module import
{ ... }:

{
  imports = [
    ./framework.nix
    ./git.nix
    ./fonts/nerd-fonts.nix
    ./terminals
    ./shell
    ./editors
    ./packages
  ];
}