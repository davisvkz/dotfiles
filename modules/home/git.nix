{
	config,
	lib,
	osConfig,
	...
}: let
	cfg = config.profiles.git;
in {
	options.profiles.git.enable = lib.mkEnableOption "Git and GitHub CLI";

	config =
		lib.mkIf (cfg.enable && osConfig != null) {
			programs.git = {
				enable = true;
				settings.user = {
					email = osConfig.settings.identity.email;
					name = osConfig.settings.identity.username;
				};
			};

			programs.gh = {
				enable = true;
				gitCredentialHelper = {enable = true;};
			};
		};
}
