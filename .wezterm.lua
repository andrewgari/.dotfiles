-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action -- Action API alias

-- This table will hold the configuration
local config = {}
config.enable_kitty_keyboard_protocol = true
-- or potentially settings related to 'modifyOtherKeys'
-- In newer versions of Wezterm, use the config_builder which allows applying
-- multiple defaults sources.
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- ========= Background Image =========

-- IMPORTANT: Replace this path with the ACTUAL path where you saved the image!
local background_image_path = "./wallpaper.png" -- Linux/macOS example
-- ========= Background Image =========

-- Check if the file exists before setting it
local f = io.open(background_image_path, "r")
if f then
	config.window_background_image = background_image_path

	-- Dim the background image to make text more readable
	-- Brightness: 0.0 (black) to 1.0 (original). Lower values dim more.
	config.window_background_image_hsb = {
		brightness = 0.3, -- Adjust this value (0.1 to 0.5 is usually good)
		hue = 1.0,
		saturation = 1.0,
	}

	-- Optional: Set text background opacity
	-- If text is still hard to read, make the cell background less transparent
	-- config.text_background_opacity = 0.5

	f:close() -- Close the file handle
else
	wezterm.log_error("Background image file not found at: " .. background_image_path)
end

-- ========= Theme and Appearance =========
-- (Rest of the config follows...)
-- local background_image_path = 'C:\\Users\\YourUser\\Pictures\\image_bf0ab3.jpg' -- Windows example

-- Check if the file exists before setting it
local f = io.open(background_image_path, "r")
if f then
	config.window_background_image = background_image_path
	-- Optional: Control how the image scales
	-- "Scale" - Scale preserving aspect ratio (may leave borders)
	-- "Cover" - Scale to cover the whole area (may crop)
	-- "Tile"  - Repeat the image
	-- "Stretch" - Stretch to fill (distorts aspect ratio)
	config.window_background_image_scale = "Cover" -- Try "Cover" or "Scale"

	-- Dim the background image to make text more readable
	-- Brightness: 0.0 (black) to 1.0 (original). Lower values dim more.
	-- Saturation/Hue: 1.0 is original color.
	config.window_background_image_hsb = {
		brightness = 0.3, -- Adjust this value (0.1 to 0.5 is usually good)
		hue = 1.0,
		saturation = 1.0,
	}

	-- Optional: Set text background opacity
	-- If text is still hard to read, make the cell background less transparent
	-- 0.0 is fully transparent, 1.0 is fully opaque
	-- config.text_background_opacity = 0.5

	f:close() -- Close the file handle
else
	wezterm.log_error("Background image file not found at: " .. background_image_path)
end

-- ========= Theme and Appearance =========

-- Choose a color scheme. A less busy one might work better with a background image.
-- Maybe try something like 'Gruvbox dark, hard (base16)', 'Nord', or a simpler one.
-- Or stick with your preference and adjust dimming/opacity above.
config.color_scheme = "Gruvbox dark, hard (base16)" -- Example, change if needed

-- Font configuration (using FiraCode Nerd Font as example)
config.font = wezterm.font_with_fallback({
	"FiraCode Nerd Font",
	"Symbols Nerd Font Mono",
	"Noto Color Emoji",
})
config.font_size = 11.0

-- Enable font ligatures
config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }

-- Window padding
config.window_padding = {
	left = 10,
	right = 10,
	top = 10,
	bottom = 5,
}

-- Tab bar settings
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true

-- ========= Keybindings =========
-- (Using the same keybindings as the previous example)
wezterm.log_info("Using custom keybindings")
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
	-- macOS Option key as Meta
	{ key = "LeftArrow", mods = "OPT", action = act.SendString("\x1bb") },
	{ key = "RightArrow", mods = "OPT", action = act.SendString("\x1bf") },
	-- Pane Splitting
	{ key = "%", mods = "SHIFT|ALT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = '"', mods = "SHIFT|ALT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	-- Pane Navigation
	{ key = "h", mods = "ALT", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "ALT", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "ALT", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "ALT", action = act.ActivatePaneDirection("Right") },
	-- Pane Resizing
	{ key = "H", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
	{ key = "J", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },
	{ key = "K", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },
	{ key = "L", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },
	-- Pane Management
	{ key = "z", mods = "ALT", action = act.TogglePaneZoomState },
	{ key = "x", mods = "ALT", action = act.CloseCurrentPane({ confirm = true }) },
	-- Tab Navigation
	{ key = "[", mods = "ALT", action = act.ActivateTabRelative(-1) },
	{ key = "]", mods = "ALT", action = act.ActivateTabRelative(1) },
	{ key = "n", mods = "ALT", action = act.ShowTabNavigator },
	-- Tab Management
	{ key = "t", mods = "SUPER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "w", mods = "SUPER", action = act.CloseCurrentTab({ confirm = true }) },
	{ key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },
	{ key = "Tab", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
	-- Copy/Paste
	{ key = "c", mods = "SUPER", action = act.CopyTo("Clipboard") },
	{ key = "v", mods = "SUPER", action = act.PasteFrom("Clipboard") },
	-- Font size
	{ key = "+", mods = "CTRL", action = act.IncreaseFontSize },
	{ key = "-", mods = "CTRL", action = act.DecreaseFontSize },
	{ key = "0", mods = "CTRL", action = act.ResetFontSize },
	-- Scrollback
	{ key = "PageUp", mods = "SHIFT", action = act.ScrollByPage(-1) },
	{ key = "PageDown", mods = "SHIFT", action = act.ScrollByPage(1) },
	-- Launchers
	{ key = "L", mods = "CTRL|SHIFT", action = act.ShowLauncher },
	{ key = "P", mods = "CTRL|SHIFT", action = act.ActivateCommandPalette },
	-- URL Selection
	{
		key = "u",
		mods = "CTRL|SHIFT",
		action = act.QuickSelectArgs({
			label = "open url",
			patterns = { "\\b\\w+://(?:[\\w.-]+|\\ P {Ip_Address})(?::\\d+)?(?:/\\S*)?" },
			action = wezterm.action_callback(function(window, pane)
				local url = window:get_selection_text_for_pane(pane)
				wezterm.log_info("Opening URL: " .. url)
				wezterm.open_with(url)
			end),
		}),
	},
}
-- Add bindings for Super+1..9
for i = 1, 9 do
	table.insert(config.keys, { key = tostring(i), mods = "SUPER", action = act.ActivateTab(i - 1) })
end

-- ========= Status Bar =========
-- (Using the same status bar setup as before)
config.enable_tab_bar = true
local function get_git_branch()
	local success, stdout, _ = wezterm.run_child_process({ "git", "rev-parse", "--abbrev-ref", "HEAD" })
	if success then
		local branch = stdout:gsub("[\r\n]", "")
		if branch ~= "" then
			return "  " .. branch
		end
	end
	return ""
end
local function format_cwd(cwd)
	local home = os.getenv("HOME")
	if home and cwd:find(home, 1, true) == 1 then
		cwd = "~" .. cwd:sub(#home + 1)
	end
	return "  " .. cwd
end
wezterm.on("update-right-status", function(window, pane)
	local elements = {}
	local git_branch = get_git_branch()
	if git_branch ~= "" then
		table.insert(elements, git_branch)
	end
	local cwd = pane:get_current_working_dir()
	if cwd then
		table.insert(elements, format_cwd(cwd.path))
	end
	table.insert(elements, " 󰣇 " .. window:active_workspace())
	table.insert(elements, "  " .. wezterm.strftime("%H:%M"))
	window:set_right_status(wezterm.format(elements))
end)
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local pane = tab.active_pane
	local title = pane.title
	local index = tab.tab_index + 1
	local prefix = string.format("%d: ", index)
	max_width = max_width - wezterm.nerd_glyph_width(prefix) - 1
	if #title > max_width then
		title = wezterm.truncate_right(title, max_width)
	end
	return { { Text = prefix .. title } }
end)

-- ========= Other Settings =========
config.scrollback_lines = 5000
config.hyperlink_rules = wezterm.default_hyperlink_rules()
config.default_domain = "local"
config.audible_bell = "Disabled"
config.window_close_confirmation = "AlwaysPrompt"

-- ========= Final Return =========
return config
