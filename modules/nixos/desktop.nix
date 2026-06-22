{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.desktop;
	homeDir = config.settings.identity.homeDirectory;
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
				configFile = "${homeDir}/.config/bspwm/bspwmrc";
				sxhkd.configFile = "${homeDir}/.config/sxhkd/sxhkdrc";
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
	};
}
