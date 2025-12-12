-- Wezterm configuration matching kitty setup
local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Font settings
config.font = wezterm.font("Hack Nerd Font")
config.font_size = 12.0

-- Window appearance
config.window_background_opacity = 0.9

-- Slightly dim text when unfocused
wezterm.on("window-focus-changed", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	if window:is_focused() then
		overrides.colors = nil
	else
		overrides.colors = {
			foreground = "#a9b1d6",
		}
	end
	window:set_config_overrides(overrides)
end)

config.window_padding = {
	left = 4,
	right = 4,
	top = 4,
	bottom = 4,
}

-- Tokyo Night color scheme
config.color_scheme = "Tokyo Night"

-- Cursor settings
config.default_cursor_style = "SteadyBlock"
config.cursor_blink_rate = 500

-- Tab bar
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false

-- Window decorations
config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"

-- Initial window size (avoids resize flash when tiling)
config.initial_cols = 120
config.initial_rows = 30

-- Scrollback
config.scrollback_lines = 2000

-- Disable audio bell
config.audible_bell = "Disabled"

-- Wayland/X11
config.enable_wayland = false

-- Performance
config.front_end = "WebGpu"

-- Key bindings (some useful defaults)
config.keys = {
	-- Copy/Paste
	{ key = "Copy", mods = "NONE", action = wezterm.action.CopyTo("Clipboard") },
	{ key = "Paste", mods = "NONE", action = wezterm.action.PasteFrom("Clipboard") },
	{ key = "c", mods = "SHIFT|CTRL", action = wezterm.action.CopyTo("Clipboard") },
	{ key = "v", mods = "SHIFT|CTRL", action = wezterm.action.PasteFrom("Clipboard") },
	{ key = "c", mods = "SUPER", action = wezterm.action.CopyTo("Clipboard") },
	{ key = "v", mods = "SUPER", action = wezterm.action.PasteFrom("Clipboard") },

	-- New tab
	{ key = "t", mods = "CTRL|SHIFT", action = wezterm.action.SpawnTab("CurrentPaneDomain") },

	-- Close tab
	{ key = "w", mods = "CTRL|SHIFT", action = wezterm.action.CloseCurrentTab({ confirm = false }) },

	-- Tab navigation
	{ key = "Tab", mods = "CTRL", action = wezterm.action.ActivateTabRelative(1) },
	{ key = "Tab", mods = "CTRL|SHIFT", action = wezterm.action.ActivateTabRelative(-1) },

	-- Split panes
	{ key = "d", mods = "CTRL", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "D", mods = "CTRL", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },

	-- Font size
	{ key = "+", mods = "CTRL|SHIFT", action = wezterm.action.IncreaseFontSize },
	{ key = "-", mods = "CTRL", action = wezterm.action.DecreaseFontSize },
	{ key = "0", mods = "CTRL", action = wezterm.action.ResetFontSize },
}

-- Mouse bindings
config.mouse_bindings = {
	-- Right click paste
	{
		event = { Down = { streak = 1, button = "Right" } },
		mods = "NONE",
		action = wezterm.action.PasteFrom("Clipboard"),
	},
}

return config
