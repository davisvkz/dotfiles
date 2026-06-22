{
	config,
	lib,
	pkgs,
	inputs,
	...
}: let
	cfg = config.profiles.apps.winapps;
in {
	options.profiles.apps.winapps.enable = lib.mkEnableOption "WinApps (run Windows applications via KVM)";

	config = lib.mkIf cfg.enable {
		home.packages = [
			inputs.winapps.packages.${pkgs.system}.winapps
			inputs.winapps.packages.${pkgs.system}.winapps-launcher
		];
	};
}
