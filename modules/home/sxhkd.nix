{
	config,
	lib,
	pkgs,
	flake,
	...
}: let
	cfg = config.profiles.sxhkd;
	sxhkd_dir = "${flake}/dotfiles/sxhkd";
in {
	options.profiles.sxhkd.enable = lib.mkEnableOption "sxhkd hotkey daemon config";

	config = lib.mkIf cfg.enable {
		home.packages = [ pkgs.sxhkd ];

		xdg.configFile."sxhkd/sxhkdrc".source = "${sxhkd_dir}/sxhkdrc";
	};
}
