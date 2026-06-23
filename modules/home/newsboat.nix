{
	config,
	lib,
	pkgs,
	flake,
	...
}: let
	cfg = config.profiles.newsboat;
	nb_dir = "${flake}/hosts/nixos/users/davisvkz/config/newsboat";
in {
	options.profiles.newsboat.enable = lib.mkEnableOption "newsboat RSS reader";

	config = lib.mkIf cfg.enable {
		home.packages = [ pkgs.newsboat ];

		# Link the raw config and urls files — preserves comments and groupings
		xdg.configFile = {
			"newsboat/config".source = "${nb_dir}/config";
			"newsboat/urls".source = "${nb_dir}/urls";
		};
	};
}
