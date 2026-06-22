{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.desktop;
in {
	options.profiles.desktop.enable = lib.mkEnableOption "Desktop theming, WM tools and X11 utilities";

	config = lib.mkIf cfg.enable {
		dconf.enable = true;
		dconf.settings = {
			"org/gnome/desktop/interface" = {color-scheme = "prefer-dark";};
		};

		gtk = {
			enable = true;
			theme = {
				name = "Adwaita-dark";
				package = pkgs.gnome-themes-extra;
			};
			gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
			gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
		};

		qt = {
			enable = true;
			style = {name = "adwaita-dark";};
		};

		xdg.portal = {
			extraPortals = [pkgs.xdg-desktop-portal-gtk];
			config.common.default = "gtk";
		};

		home.packages = with pkgs; [
			# Barra / lançador
			polybar
			rofi
			dmenu
			dunst

			# WM / hotkeys
			sxhkd
			tabbed

			# Controle de tela / X11
			arandr
			brightnessctl
			xclip
			xsel
			xpaste
			xclicker
			xcolor
			sxcs
			xev
			xeyes

			# Áudio (controle userspace)
			pavucontrol
			pulseaudio

			# Notificações / fontes / misc
			libnotify
			dconf
			gnome-font-viewer

			# Bluetooth CLI
			bluez

			# Info de vídeo
			vdpauinfo
		];
	};
}
