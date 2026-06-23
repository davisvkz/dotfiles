{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.wezterm;
in {
	options.profiles.wezterm.enable = lib.mkEnableOption "WezTerm terminal emulator";

	config = lib.mkIf cfg.enable {
		programs.wezterm = {
			enable = true;
			extraConfig = ''
				local wezterm = require 'wezterm'
				local config = {}

				config.font = wezterm.font_with_fallback({
					'FiraCode Nerd Font',
					'Material Design Icons Desktop',
					'Noto Color Emoji',
					'Noto Sans',
				})

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

				wezterm.on('toggle-opacity', function(window, pane)
					local overrides = window:get_config_overrides() or {}
					if not overrides.window_background_opacity then
						overrides.window_background_opacity = 0.0
					else
						overrides.window_background_opacity = nil
					end
					window:set_config_overrides(overrides)
				end)

				config.keys = {
					{
						key = 'B',
						mods = 'CTRL',
						action = wezterm.action.EmitEvent 'toggle-opacity',
					},
				}

				return config
			'';
		};
	};
}
