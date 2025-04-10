# modules/terminals/kitty.nix
{ config, pkgs, lib, ... }:

{
  # Simple installation of kitty
  environment.systemPackages = with pkgs; [
    kitty
  ];
  
  # System-level configuration for kitty
  environment.etc."xdg/kitty/kitty.conf".text = ''
    # FONT SETTINGS
    font_family      FiraCode Nerd Font
    bold_font        auto
    italic_font      auto
    bold_italic_font auto
    font_size        12.0

    # RENDERING
    enable_ligatures        always
    disable_ligatures       never
    adjust_line_height      110%
    adjust_column_width     100%

    # COLOR SCHEME (Catppuccin Mocha)
    foreground      #cdd6f4
    background      #1e1e2e
    selection_foreground  #1e1e2e
    selection_background  #f5e0dc
    cursor         #f38ba8
    url_color      #89b4fa

    # Black
    color0  #45475a
    color8  #585b70

    # Red
    color1  #f38ba8
    color9  #f38ba8

    # Green
    color2  #a6e3a1
    color10 #a6e3a1

    # Yellow
    color3  #f9e2af
    color11 #f9e2af

    # Blue
    color4  #89b4fa
    color12 #89b4fa

    # Magenta
    color5  #cba6f7
    color13 #cba6f7

    # Cyan
    color6  #94e2d5
    color14 #94e2d5

    # White
    color7  #bac2de
    color15 #a6adc8

    # SCROLLBACK
    scrollback_lines 10000
    wheel_scroll_multiplier 5.0
    enable_audio_bell no

    # WINDOW BEHAVIOR
    window_padding_width 8
    confirm_os_window_close 0
    background_opacity 0.95

    # KEYBINDINGS
    map ctrl+shift+t new_tab
    map ctrl+shift+w close_tab
    map ctrl+shift+left previous_tab
    map ctrl+shift+right next_tab
    map ctrl+shift+up increase_font_size
    map ctrl+shift+down decrease_font_size
    map ctrl+shift+r launch --type=overlay btop
    map ctrl+shift+f launch --type=overlay ranger
    map ctrl+shift+c copy_to_clipboard
    map ctrl+shift+v paste_from_clipboard

    # SHELL SETTINGS
    shell zsh
  '';
}