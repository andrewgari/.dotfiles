# modules/terminals/alacritty.nix
{ config, pkgs, lib, ... }:

{
  # Install required packages
  environment.systemPackages = with pkgs; [
    alacritty
    jetbrains-mono
  ];
  
  # System-level configuration for Alacritty
  environment.etc."xdg/alacritty/alacritty.yml".text = ''
    # Live config reload
    live_config_reload: true
    
    # Window settings
    window:
      opacity: 0.5
      startup_mode: Windowed
      dimensions:
        columns: 100
        lines: 85
      padding:
        x: 0
        y: 0
      dynamic_padding: false

    # Scrolling
    scrolling:
      history: 10000
      multiplier: 3

    # Font configuration
    font:
      size: 14.0
      normal:
        family: JetBrains Mono
        style: Medium
      bold:
        family: JetBrains Mono
        style: Bold
      italic:
        family: JetBrains Mono
        style: Light Italic
      offset:
        x: 0
        y: 0
      glyph_offset:
        x: 0
        y: 0

    # Colors
    colors:
      primary:
        background: '0x1d1f21'
        foreground: '0xc5c8c6'
      cursor:
        text: '0x1d1f21'
        cursor: '0xc5c8c6'
      normal:
        black: '0x1d1f21'
        red: '0xcc6666'
        green: '0xb5bd68'
        yellow: '0xf0c674'
        blue: '0x81a2be'
        magenta: '0xb294bb'
        cyan: '0x8abeb7'
        white: '0xc5c8c6'
      bright:
        black: '0x969896'
        red: '0xde935f'
        green: '0x282a2e'
        yellow: '0x373b41'
        blue: '0xb4b7b4'
        magenta: '0xe0e0e0'
        cyan: '0xa3685a'
        white: '0xffffff'

    # Cursor settings
    cursor:
      style: Block
      unfocused_hollow: true

    # Selection settings
    selection:
      semantic_escape_chars: ",│`|:\"' ()[]{}<>"
      save_to_clipboard: false

    # Mouse settings
    mouse:
      hide_when_typing: true

    # Key bindings
    key_bindings:
      - { key: V, mods: Command, action: Paste }
      - { key: C, mods: Command, action: Copy }
      - { key: Q, mods: Command, action: Quit }
      - { key: N, mods: Command, action: SpawnNewInstance }
      - { key: Return, mods: Command, action: ToggleFullscreen }
      - { key: Equals, mods: Command, action: IncreaseFontSize }
      - { key: Minus, mods: Command, action: DecreaseFontSize }
      - { key: Minus, mods: Command|Shift, action: ResetFontSize }
  '';
}