{
	config,
	lib,
	...
}: {
	config = {
		nix.settings.experimental-features = ["nix-command" "flakes"];

		boot.loader.systemd-boot.enable = true;
		boot.loader.efi.canTouchEfiVariables = true;

		services.logind.settings.Login.HandleLidSwitch = "ignore";

		networking.networkmanager.enable = true;
		networking.nameservers = lib.mkDefault config.settings.dns;
		networking.resolvconf.enable = true;
		networking.firewall.enable = true;

		environment.variables.EDITOR = "nvim";
	};
}
