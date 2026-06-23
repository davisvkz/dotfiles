{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.zathura;
in {
	options.profiles.zathura.enable = lib.mkEnableOption "zathura PDF/document viewer";

	config = lib.mkIf cfg.enable {
		programs.zathura = {
			enable = true;
			options = {
				sandbox = "none";
				statusbar-h-padding = 0;
				statusbar-v-padding = 0;
				page-padding = 1;
				selection-clipboard = "clipboard";
				window-title-basename = true;
			};
		};
	};
}
