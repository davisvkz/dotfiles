{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.dev.rust;
in {
	options.profiles.dev.rust.enable = lib.mkEnableOption "Rust development (rustc, cargo)";

	config =
		lib.mkIf cfg.enable {
			home.packages = with pkgs; [
				rustc
				cargo
			];
		};
}
