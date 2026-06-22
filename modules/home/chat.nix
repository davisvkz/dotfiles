{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.chat;
in {
	options.profiles.chat.enable = lib.mkEnableOption "Chat and communication apps";

	config =
		lib.mkIf cfg.enable {
			home.packages = with pkgs; [
				# Discord
				discord
				vesktop
				betterdiscordctl

				# Outros
				slack
				telegram-desktop

				# Matrix
				element-desktop
				gomuks
				matrix-commander-rs

				# IRC / terminais
				weechat

				# Local / p2p
				localsend
			];
		};
}
