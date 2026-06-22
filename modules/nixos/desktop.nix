{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.desktop;
in {
	options.profiles.desktop.enable = lib.mkEnableOption "Desktop environment (bspwm/SDDM/picom)";

	config = lib.mkIf cfg.enable {
		services.picom = {
			enable = true;
			backend = "glx";
		};

		services.displayManager.sddm.enable = true;

		services.xserver = {
			enable = true;
			xkb = {
				layout = "br";
				variant = "";
			};
			windowManager.bspwm = {
				enable = true;
				configFile = "/home/davisvkz/.config/bspwm/bspwmrc";
				sxhkd.configFile = "/home/davisvkz/.config/sxhkd/sxhkdrc";
			};
		};

		xdg.portal = {
			enable = true;
			extraPortals = [pkgs.xdg-desktop-portal-gtk];
			config.common.default = "gtk";
		};

		hardware.bluetooth.enable = true;
		services.blueman.enable = true;

		services.flatpak.enable = true;

		services.locate = {
			enable = true;
			package = pkgs.plocate;
		};

		services.gvfs.enable = true;
		services.gnome.gnome-keyring.enable = true;
		services.dbus.enable = true;

		services.libinput = {
			enable = true;
			touchpad = {
				tapping = true;
				clickMethod = "buttonareas";
			};
		};

		fonts.fontconfig = {
			enable = true;
			defaultFonts = {
				sansSerif = ["Noto Sans CJK SC" "Noto Color Emoji" "Fira Code Nerd Font" "Material Design Icons Desktop"];
				serif = ["Merriweather" "Fira Code Nerd Font" "Noto Color Emoji" "Material Design Icons Desktop"];
				monospace = ["Fira Code Nerd Font" "Noto Color Emoji" "Material Design Icons Desktop"];
				emoji = ["Noto Color Emoji" "Material Design Icons Desktop"];
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
