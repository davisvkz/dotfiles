{
	config,
	lib,
	pkgs,
	...
}: let
	id = config.settings.identity;
in {
	config = {
		users.users.${id.username} = {
			isNormalUser = true;
			description = id.fullName;
			extraGroups = ["networkmanager" "wheel" "docker" "libvirtd" "kvm" "vboxusers"];
			shell = pkgs.zsh;
		};

		programs.gnupg.agent = {
			enable = true;
			pinentryPackage = pkgs.pinentry-rofi;
			enableSSHSupport = true;
		};

		programs.zsh.enable = true;
	};
}
