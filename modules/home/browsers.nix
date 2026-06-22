{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.browsers;
in {
	options.profiles.browsers.enable = lib.mkEnableOption "Web browsers";

	config =
		lib.mkIf cfg.enable {
			home.packages = with pkgs; [
				firefox
				firefox-devedition
				chromium
				google-chrome
			];
		};
}
