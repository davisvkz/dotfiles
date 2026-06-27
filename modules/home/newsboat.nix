{
	config,
	lib,
	flake,
	...
}: let
	cfg = config.profiles.newsboat;
	nb_dir = "${flake}/dotfiles/newsboat";
in {
	options.profiles.newsboat.enable = lib.mkEnableOption "newsboat RSS reader";

	config = lib.mkIf cfg.enable {
		programs.newsboat = {
			enable = true;
			# urls = [] (padrão) → módulo não escreve o arquivo de urls
			extraConfig = builtins.readFile "${nb_dir}/config";
		};

		# Arquivo de feeds gerenciado separadamente (módulo só grava quando urls != [])
		xdg.configFile."newsboat/urls".source = "${nb_dir}/urls";
	};
}
