# modules/alacritty.nix
{ config, pkgs, lib, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      live_config_reload = true;
      
      window = {
        dynamic_padding = false;
        opacity = 0.5;
        startup_mode = "Windowed";
        dimensions = {
          columns = 100;
          lines = 85;
        };
        padding = {
          x = 0;
          y = 0;
        };
      };
      
      scrolling = {
        history = 10000;
        multiplier = 3;
      };
      
      font = {
        size = 14.0;
        normal = {
          family = "JetBrains Mono";
          style = "Medium";
        };
        bold = {
          family = "JetBrains Mono";
          style = "Bold";
        };
        italic = {
          family = "JetBrains Mono";
          style = "Light Italic";
        };
        offset = {
          x = 0;
          y = 0;
        };
        glyph_offset = {
          x = 0;
          y = 0;
        };
      };
      
      draw_bold_text_with_bright_colors = false;
      
      colors = {
        primary = {
          background = "0x1d1f21";
          foreground = "0xc5c8c6";
        };
        cursor = {
          text = "0x1d1f21";
          cursor = "0xc5c8c6";
        };
        normal = {
          black = "0x1d1f21";
          red = "0xcc6666";
          green = "0xb5bd68";
          yellow = "0xf0c674";
          blue = "0x81a2be";
          magenta = "0xb294bb";
          cyan = "0x8abeb7";
          white = "0xc5c8c6";
        };
        bright = {
          black = "0x969896";
          red = "0xde935f";
          green = "0x282a2e";
          yellow = "0x373b41";
          blue = "0xb4b7b4";
          magenta = "0xe0e0e0";
          cyan = "0xa3685a";
          white = "0xffffff";
        };
      };
      
      bell = {
        animation = "EaseOutExpo";
        color = "0xffffff";
        duration = 0;
      };
      
      cursor = {
        style = "Block";
        unfocused_hollow = true;
      };
      
      selection = {
        semantic_escape_chars = ",│`|:\"' ()[]{}<>";
        save_to_clipboard = false;
      };
      
      mouse = {
        hide_when_typing = true;
        bindings = [
          {
            mouse = "Middle";
            action = "PasteSelection";
          }
        ];
      };
      
      debug = {
        render_timer = false;
        persistent_logging = false;
        log_level = "OFF";
      };
      
      # Your key bindings
      keyboard.bindings = [
        { key = "V"; mods = "Command"; action = "Paste"; }
        { key = "C"; mods = "Command"; action = "Copy"; }
        { key = "Q"; mods = "Command"; action = "Quit"; }
        { key = "N"; mods = "Command"; action = "SpawnNewInstance"; }
        { key = "Return"; mods = "Command"; action = "ToggleFullscreen"; }
        { key = "Home"; mode = "AppCursor"; chars = "\u001BOH"; }
        { key = "Home"; mode = "~AppCursor"; chars = "\u001B[H"; }
        { key = "End"; mode = "AppCursor"; chars = "\u001BOF"; }
        { key = "End"; mode = "~AppCursor"; chars = "\u001B[F"; }
        { key = "Equals"; mods = "Command"; action = "IncreaseFontSize"; }
        { key = "Minus"; mods = "Command"; action = "DecreaseFontSize"; }
        { key = "Minus"; mods = "Command|Shift"; action = "ResetFontSize"; }
        # Plus many more key bindings...
        # I'm including just a sample here for brevity
      ];
    };
  };
  
  # Make sure the alacritty package is installed
  environment.systemPackages = with pkgs; [
    alacritty
    # Make sure JetBrains Mono font is available
    jetbrains-mono
  ];
}
