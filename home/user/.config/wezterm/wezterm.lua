local wezterm = require 'wezterm'
local config = {}
config.font = wezterm.font 'FiraCode Nerd Font'
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}
config.exit_behavior = 'Close'
config.exit_behavior_messaging = 'None'
config.enable_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.window_close_confirmation = 'NeverPrompt'
config.font = wezterm.font_with_fallback({
  'FiraCode Nerd Font',
	--  'Material Design Icons Desktop',
  'Noto Color Emoji',
  'Noto Sans',
})
return config
