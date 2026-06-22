{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.dev.cpp;
in {
	options.profiles.dev.cpp.enable = lib.mkEnableOption "C/C++ development (gcc, cmake, make, pkg-config)";

	config =
		lib.mkIf cfg.enable {
			home.packages = with pkgs; [
				gcc
				cmake
				gnumake
				pkg-config
			];
		};
}
