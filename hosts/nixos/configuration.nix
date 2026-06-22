{
	pkgs,
	flake,
	...
}: {
	imports = [
		./hardware-configuration.nix
		./hardware.nix
		"${flake}/modules/nixos/all.nix"
	];

	# ── Profiles ────────────────────────────────────────────────────────────────
	profiles = {
		desktop.enable = true;
		audio.enable = true;
		gaming.enable = true;
		virtualisation.enable = true;
		devtools.enable = true;
	};

	# ── Hardware / GPU ───────────────────────────────────────────────────────────
	# Intel VAAPI (host-specific; NVIDIA PRIME gerenciado por hardware.nix)
	hardware.graphics = {
		enable = true;
		enable32Bit = true;
		extraPackages = with pkgs; [
			libva
			libva-utils
			intel-media-driver
			libva-vdpau-driver
			libvdpau-va-gl
		];
	};
	environment.variables.LIBVA_DRIVER_NAME = "iHD";

	# ── Networking (portas específicas desta máquina) ────────────────────────────
	networking.firewall.allowedTCPPorts = [8080 5984];

	# ── Pacotes (específicos do host) ────────────────────────────────────────────
	environment.systemPackages = with pkgs; [
		home-manager
		qemu
		virt-manager
	];

	# ── Misc ────────────────────────────────────────────────────────────────────
	# Symlink para apps que esperam Chrome em path FHS fixo
	systemd.tmpfiles.rules = [
		"d /opt/google/chrome 0755 root root -"
		"L+ /opt/google/chrome/chrome - - - - ${pkgs.google-chrome}/bin/google-chrome-stable"
	];

	system.stateVersion = "26.05";
}
