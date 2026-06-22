{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.dev.core;
in {
	options.profiles.dev.core.enable = lib.mkEnableOption "Core dev tools (git, editors, Nix LSPs, dev libs)";

	config = lib.mkIf cfg.enable {
		home.packages = with pkgs; [
			# Git
			lazygit
			gitkraken
			github-desktop
			git-filter-repo

			# Editors / IDEs
			vscode

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
