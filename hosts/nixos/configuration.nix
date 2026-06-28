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
		media.enable = true;
		gaming.enable = true;
		virtualisation.enable = true;
		devtools.enable = true;
		chromeFhs.enable = true;
		ssh.enable = true;
	};

	# ── Networking (host-specific ports) ────────────────────────────────────────
	# 8080: generic dev server, 5984: CouchDB
	networking.firewall.allowedTCPPorts = [8080 5984];

	# ── Packages (host-specific) ─────────────────────────────────────────────────
	environment.systemPackages = with pkgs; [
		home-manager
		qemu
		virt-manager
	];

	system.stateVersion = "26.05";
}
