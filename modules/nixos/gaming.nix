{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.gaming;
in {
	options.profiles.gaming.enable = lib.mkEnableOption "Gaming (Steam + gamemode)";

	config =
		lib.mkIf cfg.enable {
			programs.steam = {
				enable = true;
				remotePlay.openFirewall = true;
				dedicatedServer.openFirewall = true;
				localNetworkGameTransfers.openFirewall = true;
				protontricks.enable = true;
				extraPackages = with pkgs; [
					steamtinkerlaunch
					yad
					xdotool
					unzip
					cabextract
					p7zip
				];
				extraCompatPackages = with pkgs; [
					steamtinkerlaunch
					proton-ge-bin
				];
			};

			programs.gamemode.enable = true;
		};
}
