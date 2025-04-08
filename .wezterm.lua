local wezterm = require 'wezterm'
local config = {}

-- Tokyo Night palette based on theme 
local tokyonight_colors = {
  fg = '#c0caf5',       -- Foreground text
  fg_dark = '#a9b1d6',  -- Darker foreground
  bg = '#1a1b26',       -- Main background
  bg_dark = '#16161e',  -- Darker background (status line)
  bg_highlight = '#292e42', -- Selection background
  terminal_black = '#414868', -- Muted text/comments
  blue = '#7aa2f7',     -- Bright blue
  cyan = '#7dcfff',     -- Cyan/Aqua
  green = '#9ece6a',    -- Green
  orange = '#ff9e64',   -- Orange
  magenta = '#bb9af7',  -- Purple/Magenta
  red = '#f7768e',      -- Red
  yellow = '#e0af68',   -- Yellow
}

-- Create our custom Tokyo Night theme
config.color_schemes = {
  ['TokyoNightRainbow'] = {
    -- Base colors
    foreground = tokyonight_colors.fg,
    background = tokyonight_colors.bg,
    cursor_bg = tokyonight_colors.fg,
    cursor_fg = tokyonight_colors.bg,
    cursor_border = tokyonight_colors.fg,
    
    -- Selection
    selection_fg = tokyonight_colors.fg,
    selection_bg = tokyonight_colors.bg_highlight,
    
    -- The 16 ANSI colors
    ansi = {
      tokyonight_colors.bg_dark,   -- black 
      tokyonight_colors.red,       -- red
      tokyonight_colors.green,     -- green
      tokyonight_colors.yellow,    -- yellow
      tokyonight_colors.blue,      -- blue
      tokyonight_colors.magenta,   -- magenta/purple
      tokyonight_colors.cyan,      -- cyan
      tokyonight_colors.fg_dark,   -- white (but actually gray)
    },
    
    brights = {
      tokyonight_colors.terminal_black, -- bright black
      '#ff7a93',                   -- bright red
      '#b9f27c',                   -- bright green
      '#ff9e64',                   -- bright yellow/orange
      '#7da6ff',                   -- bright blue
      '#bb9af7',                   -- bright magenta/purple
      '#0db9d7',                   -- bright cyan
      '#c0caf5',                   -- bright white
    },
    
    -- Tab bar
    tab_bar = {
      background = tokyonight_colors.bg_dark,
      active_tab = {
        bg_color = tokyonight_colors.blue,
        fg_color = tokyonight_colors.bg_dark,
      },
      inactive_tab = {
        bg_color = tokyonight_colors.bg_dark,
        fg_color = tokyonight_colors.fg_dark,
      },
      inactive_tab_hover = {
        bg_color = tokyonight_colors.bg_highlight,
        fg_color = tokyonight_colors.fg,
      },
      new_tab = {
        bg_color = tokyonight_colors.bg_dark,
        fg_color = tokyonight_colors.fg_dark,
      },
      new_tab_hover = {
        bg_color = tokyonight_colors.orange,
        fg_color = tokyonight_colors.bg_dark,
      },
    },
  }
}

-- Use our custom color scheme
config.color_scheme = "TokyoNightRainbow"

-- Rainbow-like status bar setup to match Starship's look
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.show_tab_index_in_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false

-- Configure status bar to have a Powerline appearance like Starship's rainbow
wezterm.on('update-status', function(window, pane)
  -- Define powerline symbols
  local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
  local SOLID_RIGHT_ARROW = utf8.char(0xe0b0)
  
  -- Get basic info
  local basename = function(s)
    -- Extract basename from a path
    return string.gsub(s, "(.*[/\\])(.*)", "%2")
  end
  
  local cwd = basename(pane:get_current_working_dir():gsub("file://", ""))
  local host = wezterm.hostname()
  local time = wezterm.strftime("%H:%M")
  
  -- Get workspace name if any
  local workspace = window:active_workspace()
  
  -- Format the status line with rainbow segments similar to Starship
  local status = {}
  
  -- Left status (mimics Starship's left prompt)
  table.insert(status, {
    Background = { Color = tokyonight_colors.red },
    Foreground = { Color = tokyonight_colors.bg_dark },
    Text = " " .. host .. " ",
  })
  
  table.insert(status, {
    Background = { Color = tokyonight_colors.yellow },
    Foreground = { Color = tokyonight_colors.red },
    Text = SOLID_RIGHT_ARROW,
  })
  
  table.insert(status, {
    Background = { Color = tokyonight_colors.yellow },
    Foreground = { Color = tokyonight_colors.bg_dark },
    Text = " " .. cwd .. " ",
  })
  
  table.insert(status, {
    Background = { Color = tokyonight_colors.green },
    Foreground = { Color = tokyonight_colors.yellow },
    Text = SOLID_RIGHT_ARROW,
  })
  
  table.insert(status, {
    Background = { Color = tokyonight_colors.green },
    Foreground = { Color = tokyonight_colors.bg_dark },
    Text = " " .. workspace .. " ",
  })
  
  table.insert(status, {
    Background = { Color = tokyonight_colors.cyan },
    Foreground = { Color = tokyonight_colors.green },
    Text = SOLID_RIGHT_ARROW,
  })
  
  -- Right status 
  table.insert(status, {
    Background = { Color = tokyonight_colors.bg_dark },
    Foreground = { Color = tokyonight_colors.blue },
    Text = SOLID_LEFT_ARROW,
  })
  
  table.insert(status, {
    Background = { Color = tokyonight_colors.bg_dark },
    Foreground = { Color = tokyonight_colors.fg },
    Text = " " .. time .. " ",
  })
  
  window:set_right_status(wezterm.format(status))
end)

-- Font configuration
config.font = wezterm.font_with_fallback({
  'JetBrains Mono',
  'FiraCode Nerd Font',
})
config.font_size = 12.0
config.line_height = 1.1

-- Window appearance
config.window_padding = {
  left = '1cell',
  right = '1cell',
  top = '0.5cell',
  bottom = '0.5cell',
}

-- Let's make it a bit transparent to show off
config.window_background_opacity = 0.92
config.text_background_opacity = 1.0

-- Optional subtle background image for more Tokyo vibes
-- Uncomment these lines and provide your own background image path if desired
-- config.window_background_image = '/path/to/your/tokyo-skyline.jpg'
-- config.window_background_image_hsb = {
--   brightness = 0.02,
--   hue = 1.0,
--   saturation = 1.0,
-- }

-- Keybindings for workspaces (optional)
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
  -- Switch between workspaces
  {
    key = 'w',
    mods = 'LEADER',
    action = wezterm.action.ShowLauncherArgs { flags = 'WORKSPACES' },
  },
  -- Create a new workspace
  {
    key = 'n',
    mods = 'LEADER',
    action = wezterm.action.PromptInputLine {
      description = 'Enter name for new workspace',
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:perform_action(
            wezterm.action.SwitchToWorkspace {
              name = line,
            },
            pane
          )
        end
      end),
    },
  },
}

-- Add a keybinding to switch between tokyonight and other themes
-- that would complement your starship theme
config.key_tables = {
  toggle_themes = {
    { key = 't', action = wezterm.action_callback(function(window, pane)
        local overrides = window:get_config_overrides() or {}
        if overrides.color_scheme == "TokyoNightRainbow" then
          overrides.color_scheme = "Tokyo Night Storm"
        elseif overrides.color_scheme == "Tokyo Night Storm" then
          overrides.color_scheme = "Tokyo Night Day"
        else
          overrides.color_scheme = "TokyoNightRainbow"
        end
        window:set_config_overrides(overrides)
      end),
    },
    { key = 'Escape', action = 'PopKeyTable' },
  }
}

-- Add a key to enter the toggle_themes key table
table.insert(config.keys, {
  key = 't',
  mods = 'LEADER',
  action = wezterm.action.ActivateKeyTable { name = 'toggle_themes', one_shot = false },
})

return config
