{
	config,
	lib,
	flake,
	...
}: let
	cfg = config.profiles.bspwm;
	bspwm_dir = "${flake}/dotfiles/bspwm";
in {
	options.profiles.bspwm.enable = lib.mkEnableOption "bspwm window manager config";

	config = lib.mkIf cfg.enable {
		xdg.configFile."bspwm/bspwmrc" = {
			source = "${bspwm_dir}/bspwmrc";
			executable = true;
		};
	};
}
