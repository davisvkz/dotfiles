{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.rofi;
in {
	options.profiles.rofi.enable = lib.mkEnableOption "rofi application launcher";

	config = lib.mkIf cfg.enable {
		programs.rofi = {
			enable = true;
			# Use the stable theme name instead of a hardcoded /nix/store path
			theme = "DarkBlue";
		};
	};
}
