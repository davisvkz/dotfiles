{
	config,
	lib,
	pkgs,
	flake,
	...
}: let
	cfg = config.profiles.shell;
	shell_dir = "${flake}/hosts/nixos/users/davisvkz/config/shell";
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

			# Shell helper files sourced by .zshrc / .zprofile
			xdg.configFile = {
				"shell/aliasrc".text = builtins.readFile "${shell_dir}/aliasrc";
				"shell/profile".text = builtins.readFile "${shell_dir}/profile";
				"shell/inputrc".text = builtins.readFile "${shell_dir}/inputrc";
				"shell/shortcutrc".text = builtins.readFile "${shell_dir}/shortcutrc";
				"shell/shortcutenvrc".text = builtins.readFile "${shell_dir}/shortcutenvrc";
				"shell/zshnameddirrc".text = builtins.readFile "${shell_dir}/zshnameddirrc";
				"shell/bm-dirs".text = builtins.readFile "${shell_dir}/bm-dirs";
				"shell/bm-files".text = builtins.readFile "${shell_dir}/bm-files";
			};
		};
}
