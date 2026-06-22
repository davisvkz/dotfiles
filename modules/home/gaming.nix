{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.gaming;
in {
	options.profiles.gaming.enable = lib.mkEnableOption "Gaming tools and launchers";

	config = lib.mkIf cfg.enable {
		home.packages = with pkgs; [
			# Launchers
			prismlauncher
			atlauncher
			hydralauncher
			itch
			r2modman

			# Minecraft / mods
			ferium
			packwiz

			# Wine / Proton
			protontricks
			steamtinkerlaunch
			winetricks
			wineWow64Packages.stable
			dxvk

			# Gaming auxiliares
			gamescope
			ruffle
		];
	};
}
