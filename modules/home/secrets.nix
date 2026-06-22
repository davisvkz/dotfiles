{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.secrets;
in {
	options.profiles.secrets.enable = lib.mkEnableOption "Secrets management (GPG, pass, pass-secret-service)";

	config =
		lib.mkIf cfg.enable {
			programs.gpg = {enable = true;};

			services.gpg-agent = {
				enable = true;
				enableSshSupport = true;
				pinentry = {package = pkgs.pinentry-rofi;};
			};

			programs.password-store = {
				enable = true;
				package = pkgs.pass.withExtensions (exts: with exts; [pass-otp pass-import pass-audit]);
			};

			services.pass-secret-service = {enable = true;};
		};
}
