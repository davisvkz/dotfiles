{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.desktop;
in {
	options.profiles.desktop.enable = lib.mkEnableOption "Desktop WM tools and X11 utilities";

	config =
		lib.mkIf cfg.enable {
			# Notificações via módulo HM
			services.dunst.enable = true;

			home.packages = with pkgs; [
				# Barra / lançador (polybar gerenciado por profiles.polybar, rofi por profiles.rofi)
				dmenu

				# WM / hotkeys (sxhkd gerenciado por profiles.sxhkd, dunst por services.dunst)
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
