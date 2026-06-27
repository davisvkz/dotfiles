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
			programs.firefox.enable = true;
			programs.chromium.enable = true;

			# Variantes sem módulo HM dedicado
			home.packages = with pkgs; [
				firefox-devedition
				google-chrome
			];
		};
}
