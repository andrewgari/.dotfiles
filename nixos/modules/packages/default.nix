# Package modules
{ ... }:

{
  imports = [
    ./browsers.nix
    ./dev-tools.nix
    ./editors.nix
    ./system-tools.nix
    ./desktop-apps.nix
    ./virtualization.nix
  ];
}