# Text editor packages
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vscode
    gedit
    obsidian
    
    # Neovim and plugins added here to ensure they're always installed
    # even though nvim config is in editors module
    neovim
    vimPlugins.LazyVim
    vimPlugins.nvim-treesitter
    vimPlugins.vim-git
  ];
}