{
	config,
	lib,
	...
}: let
	cfg = config.profiles.kdeconnect;
in {
	options.profiles.kdeconnect.enable = lib.mkEnableOption "KDE Connect (phone integration)";

	config =
		lib.mkIf cfg.enable {
			services.kdeconnect = {
				enable = true;
				indicator = true;
			};
		};
}
