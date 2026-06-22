{
	config,
	lib,
	pkgs,
	flake,
	...
}: let
	cfg = config.profiles.shell;
in {
	options.profiles.shell.enable = lib.mkEnableOption "Shell configuration (zsh, aliases, session variables)";

	config =
		lib.mkIf cfg.enable {
			home = {
				shellAliases = {magick_cli = "magick";};
				shell.enableZshIntegration = true;
				sessionVariables = {
					PLANTUML_JAR = "${pkgs.plantuml}/lib/plantuml.jar";
				};
			};

			programs.zsh = {
				enable = true;
				# dotDir not overridden: with xdg.enable + stateVersion 26.05 the default
				# is ~/.config/zsh, so HM exports ZDOTDIR reliably.
				initContent = lib.mkAfter (builtins.readFile "${flake}/hosts/nixos/users/davisvkz/config/.zshrc");
			};
		};
}
