{
	config,
	lib,
	flake,
	...
}: let
	cfg = config.profiles.wmX11;
	dwm_dir = "${flake}/hosts/nixos/users/davisvkz/config/dwm";
	x11_dir = "${flake}/hosts/nixos/users/davisvkz/config/x11";
in {
	options.profiles.wmX11.enable = lib.mkEnableOption "X11 WM helpers (dwm autostart, xprofile)";

	config = lib.mkIf cfg.enable {
		# xprofile is sourced by the display manager on X11 login
		home.file.".xprofile".source = "${x11_dir}/xprofile";

		xdg.configFile."dwm/autostart.sh" = {
			source = "${dwm_dir}/autostart.sh";
			executable = true;
		};
	};
}
