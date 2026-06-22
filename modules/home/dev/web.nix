{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.dev.web;
in {
	options.profiles.dev.web.enable = lib.mkEnableOption "Web / E2E testing (Playwright, xvfb-run)";

	config = lib.mkIf cfg.enable {
		home.sessionVariables = {
			PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
			PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
			PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "1";
		};

		home.file.".cache/ms-playwright".source = pkgs.playwright-driver.browsers;

		home.packages = with pkgs; [
			playwright-driver.browsers
			xvfb-run
		];
	};
}
