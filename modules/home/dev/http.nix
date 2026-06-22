{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.dev.http;
in {
	options.profiles.dev.http.enable = lib.mkEnableOption "HTTP / API tools (Insomnia, Postman, ngrok, cloudflared)";

	config =
		lib.mkIf cfg.enable {
			home.packages = with pkgs; [
				insomnia
				postman
				redocly
				ngrok
				cloudflared
			];
		};
}
