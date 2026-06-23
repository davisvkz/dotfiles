{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.apps;
in {
	options.profiles.apps.enable = lib.mkEnableOption "General applications (office, readers, misc)";

	config =
		lib.mkIf cfg.enable {
			home.packages = with pkgs; [
				# Notas / produtividade
				obsidian
				obsidian-export
				notion-app-enhanced

				# Office / documentos
				libreoffice

				# Leitores de PDF / e-book (zathura gerenciado por profiles.zathura)
				evince
				xreader
				kdePackages.okular
				calibre
				koreader

				# RSS / notícias (newsboat gerenciado por profiles.newsboat)
				feedr
				rsshub
				rsstail

				# Gerenciadores de arquivos
				thunar
				kdePackages.dolphin

				# Misc desktop
				yad
				gcr
				pear-desktop
				anydesk
				qrcode
				zbar
				khal

				# Torrent / downloads
				deluge

				# Virtualização e Android (userspace)
				waydroid-helper
				cage
				xwayland
				weston
				appimage-run
				fuse
				android-tools
				scrcpy
				jmtpfs
				libmtp

				# Rede / acesso remoto
				freerdp
				noip
			];
		};
}
