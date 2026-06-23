{
	config,
	lib,
	pkgs,
	osConfig,
	...
}: let
	cfg = config.profiles.theme;
	s = osConfig.settings.theme;
in {
	options.profiles.theme.enable = lib.mkEnableOption "Desktop theming (GTK, Qt, dconf, cursor)";

	config =
		lib.mkIf (cfg.enable && osConfig != null) {
			dconf.enable = true;
			dconf.settings."org/gnome/desktop/interface" = {
				color-scheme =
					if s.preferDark
					then "prefer-dark"
					else "default";
			};

			gtk = {
				enable = true;
				theme = {
					name = s.gtkTheme;
					package = pkgs.gnome-themes-extra;
				};
				gtk3.extraConfig.gtk-application-prefer-dark-theme =
					if s.preferDark
					then 1
					else 0;
				gtk4.extraConfig.gtk-application-prefer-dark-theme =
					if s.preferDark
					then 1
					else 0;
			};

			qt = {
				enable = true;
				style.name = s.qtStyle;
			};
		};
}
