{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.virtualisation;
in {
	options.profiles.virtualisation.enable = lib.mkEnableOption "Virtualisation (libvirt, Docker, VirtualBox, Waydroid)";

	config = lib.mkIf cfg.enable {
		virtualisation = {
			libvirtd = {
				enable = true;
				qemu = {
					package = pkgs.qemu_kvm;
					swtpm.enable = true;
				};
			};
			docker = {
				enable = true;
				daemon.settings = {
					dns = config.settings.dns;
				};
			};
			virtualbox.host = {
				enable = true;
				enableExtensionPack = true;
			};
			waydroid.enable = true;
		};
	};
}
