{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.xdg;
in {
	options.profiles.xdg.enable = lib.mkEnableOption "XDG desktop entries and MIME associations";

	config =
		lib.mkIf cfg.enable {
			xdg = {
				enable = true;
				desktopEntries = {
					firefox = {
						name = "firefox";
						exec = "${pkgs.firefox}/bin/firefox";
					};
					roblox = {
						name = "roblox";
						exec = "/var/lib/flatpak/app/org.vinegarhq.Sober/current/active/export/bin/org.vinegarhq.Sober";
					};
				};
				mimeApps = {
					enable = true;
					defaultApplications = {
						"application/pdf" = "org.pwmt.zathura.desktop";
						"text/html" = "firefox.desktop";
						"text/xml" = "firefox.desktop";
						"x-scheme-handler/http" = "firefox.desktop";
						"x-scheme-handler/https" = "firefox.desktop";
						"x-scheme-handler/about" = "firefox.desktop";
						"x-scheme-handler/unknown" = "firefox.desktop";
						"x-scheme-handler/roblox-player" = "roblox.desktop";
					};
				};
			};
		};
}
