{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.desktop;
in {
	options.profiles.desktop.enable = lib.mkEnableOption "Desktop WM tools and X11 utilities";

	config = lib.mkIf cfg.enable {
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

			# Notificações / misc
			libnotify
			dconf
			gnome-font-viewer

			# Bluetooth CLI (canônico aqui)
			bluez

			# Info de vídeo
			vdpauinfo
		];
	};
}
