{
	config,
	lib,
	...
}: let
	cfg = config.profiles.dev.go;
in {
	options.profiles.dev.go.enable = lib.mkEnableOption "Go development";

	config =
		lib.mkIf cfg.enable {
			programs.go.enable = true;
		};
}
