{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.dev.go;
in {
	options.profiles.dev.go.enable = lib.mkEnableOption "Go development";

	config = lib.mkIf cfg.enable {
		home.packages = with pkgs; [
			go
		];
	};
}
