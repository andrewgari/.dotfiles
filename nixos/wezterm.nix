# modules/wezterm.nix
{ config, pkgs, lib, ... }:

{
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require("wezterm")
      local config = wezterm.config_builder()

      config.colors = {
        foreground = "#d0d0d0",
        background = "#1c2438",
        cursor_bg = "#c6c8d1",
        cursor_fg = "#1c2438",
        selection_bg = "#3d4b6b",
        selection_fg = "#c6c8d1",
        ansi = {
          "#1c2438",
          "#ff6b6b",
          "#5ec4b6",
          "#f9d76c",
          "#84a0ef",
          "#c39ac9",
          "#89dceb",
          "#c6c8d1",
        },
        brights = {
          "#394b70",
          "#ff8080",
          "#6fe0d2",
          "#ffe084",
          "#9bb2ff",
          "#dcb3e5",
          "#9aecf7",
          "#e4e6ef",
        },
      }

      -- URL handling
      config.hyperlink_rules = {
        {
          regex = "\\b\\w+://(?:[\\w.-]+)[:\\w/@?&=%+#-]*",
          format = "$0",
        },
      }

      config.keys = {
        -- Splits
        { key = "p", mods = "ALT", action = wezterm.action.SplitPane({ direction = "Right" }) },
        { key = "o", mods = "ALT", action = wezterm.action.SplitPane({ direction = "Down" }) },
        { key = "d", mods = "ALT", action = wezterm.action.SplitPane({ direction = "Down" }) },
        { key = "d", mods = "ALT|SHIFT", action = wezterm.action.SplitPane({ direction = "Right" }) },

        -- Navigation
        { key = "LeftArrow", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Left") },
        { key = "RightArrow", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Right") },
        { key = "UpArrow", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Up") },
        { key = "DownArrow", mods = "ALT", action = wezterm.action.ActivatePaneDirection("Down") },

        -- Resize
        { key = "LeftArrow", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Left", 5 }) },
        { key = "RightArrow", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Right", 5 }) },
        { key = "UpArrow", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Up", 5 }) },
        { key = "DownArrow", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Down", 5 }) },

        -- Tabs
        { key = "t", mods = "ALT", action = wezterm.action.SpawnTab("CurrentPaneDomain") },
        { key = "[", mods = "ALT", action = wezterm.action.ActivateTabRelative(-1) },
        { key = "]", mods = "ALT", action = wezterm.action.ActivateTabRelative(1) },
        { key = "1", mods = "ALT", action = wezterm.action.ActivateTab(0) },
        { key = "2", mods = "ALT", action = wezterm.action.ActivateTab(1) },
        { key = "3", mods = "ALT", action = wezterm.action.ActivateTab(2) },
        { key = "4", mods = "ALT", action = wezterm.action.ActivateTab(3) },
        { key = "5", mods = "ALT", action = wezterm.action.ActivateTab(4) },

        -- Window
        { key = "w", mods = "ALT", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
        { key = "f", mods = "ALT", action = wezterm.action.ToggleFullScreen },
        { key = "=", mods = "ALT", action = wezterm.action.IncreaseFontSize },
        { key = "-", mods = "ALT", action = wezterm.action.DecreaseFontSize },
        { key = "0", mods = "ALT", action = wezterm.action.ResetFontSize },

        -- Advanced features
        { key = "z", mods = "ALT", action = wezterm.action.TogglePaneZoomState },
        { key = "Space", mods = "ALT", action = wezterm.action.QuickSelect },
        { key = "f", mods = "ALT|SHIFT", action = wezterm.action.Search({ CaseSensitiveString = "" }) },
        { key = "r", mods = "ALT", action = wezterm.action.RotatePanes("Clockwise") },
        { key = "m", mods = "ALT", action = wezterm.action.PaneSelect({ mode = "SwapWithActive" }) },
        { key = "q", mods = "ALT", action = wezterm.action.CloseCurrentPane({ confirm = false }) },
      }

      -- Font configuration
      config.font = wezterm.font_with_fallback({
        "JetBrains Mono",
        "FiraCodeNerdFontsMono",
        "Noto Color Emoji",
      })
      config.font_size = 12
      config.line_height = 1.2
      config.harfbuzz_features = { "calt=1", "liga=1" }

      -- Window appearance
      config.window_background_opacity = 0.95
      config.window_decorations = "TITLE | RESIZE"
      config.window_padding = { left = 2, right = 2, top = 0, bottom = 0 }

      -- Tab bar
      config.use_fancy_tab_bar = true
      config.tab_bar_at_bottom = true
      config.hide_tab_bar_if_only_one_tab = true
      config.window_close_confirmation = "AlwaysPrompt"

      -- Features
      config.scrollback_lines = 10000
      config.enable_scroll_bar = true
      config.enable_wayland = true
      -- config.term = "wezterm"

      return config
    '';
  };
  
  # Install required packages
  environment.systemPackages = with pkgs; [
    wezterm
    jetbrains-mono
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    noto-fonts-emoji
  ];
}
