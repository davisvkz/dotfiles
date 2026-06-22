{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.dev.infra;
in {
	options.profiles.dev.infra.enable = lib.mkEnableOption "Infrastructure tools (Vagrant, Railway)";

	config =
		lib.mkIf cfg.enable {
			home.packages = with pkgs; [
				vagrant
				railway
			];
		};
}
