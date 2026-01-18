{
	config,
	lib,
	pkgs,
	...
}: {
	services.picom.enable = true;
	programs.zsh.enable = true;
	services.displayManager.sddm = {enable = true;};
	programs.nix-ld.enable = true;

	programs.nix-ld.libraries = with pkgs; [
		nodejs
	];
	services.xserver = {
		enable = true;
		windowManager.bspwm = {
			enable = true;
			configFile = "/home/davisvkz/.config/bspwm/bspwmrc";
			sxhkd.configFile = "/home/davisvkz/.config/sxhkd/sxhkdrc";
		};
	};
}
