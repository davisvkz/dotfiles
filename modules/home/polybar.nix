{
	config,
	lib,
	pkgs,
	flake,
	...
}: let
	cfg = config.profiles.polybar;
	polybar_dir = "${flake}/hosts/nixos/users/davisvkz/config/polybar";
in {
	options.profiles.polybar.enable = lib.mkEnableOption "polybar status bar";

	config = lib.mkIf cfg.enable {
		home.packages = [ pkgs.polybar ];

		xdg.configFile = {
			"polybar/config" = {
				source = "${polybar_dir}/config";
			};
			"polybar/launch.sh" = {
				source = "${polybar_dir}/launch.sh";
				executable = true;
			};
		};
	};
}
