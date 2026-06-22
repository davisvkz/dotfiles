{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.chromeFhs;
in {
	options.profiles.chromeFhs.enable = lib.mkEnableOption "Chrome FHS symlink (/opt/google/chrome)";

	config =
		lib.mkIf cfg.enable {
			# Symlink for apps that expect Chrome at a fixed FHS path (e.g. WinApps, Electron wrappers)
			systemd.tmpfiles.rules = [
				"d /opt/google/chrome 0755 root root -"
				"L+ /opt/google/chrome/chrome - - - - ${pkgs.google-chrome}/bin/google-chrome-stable"
			];
		};
}
