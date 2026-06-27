{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.dev.core;
in {
	options.profiles.dev.core.enable = lib.mkEnableOption "Core dev tools (git, editors, Nix LSPs, dev libs)";

	config =
		lib.mkIf cfg.enable {
			programs.vscode.enable = true;
			programs.lazygit.enable = true;

			home.packages = with pkgs; [
				# Git
				gitkraken
				github-desktop
				git-filter-repo

				# Nix LSPs
				nixd
				nil

				# Dev libs
				openssl
				alsa-lib
				alsa-lib.dev

				# Pinentry (terminal fallback)
				pinentry-curses
			];
		};
}
