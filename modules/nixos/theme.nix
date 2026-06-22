{
	config,
	lib,
	pkgs,
	...
}: let
	f = config.settings.theme.fonts;
in {
	config = {
		fonts.fontconfig = {
			enable = true;
			defaultFonts = {
				sansSerif = [f.sans f.emoji f.mono "Material Design Icons Desktop"];
				serif = [f.serif f.mono f.emoji "Material Design Icons Desktop"];
				monospace = [f.mono f.emoji "Material Design Icons Desktop"];
				emoji = [f.emoji "Material Design Icons Desktop"];
			};
		};

		fonts.packages = with pkgs; [
			freefont_ttf
			freetype
			merriweather
			noto-fonts
			noto-fonts-color-emoji
			noto-fonts-cjk-sans
			liberation_ttf
			source-sans-pro
			newcomputermodern
			cm_unicode
			mplus-outline-fonts.githubRelease
			dina-font
			proggyfonts
			nerd-fonts.fira-code
			nerd-fonts.droid-sans-mono
			typstPackages.use-tabler-icons
			ibm-plex
		];
	};
}
