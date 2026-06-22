{
	pkgs,
	flake,
	...
}: {
	imports = [
		./hardware-configuration.nix
		./my-hardware.nix
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

	# ── System ──────────────────────────────────────────────────────────────────
	nix.settings.experimental-features = ["nix-command" "flakes"];

	nixpkgs.config.allowUnfree = true;
	nixpkgs.config.permittedInsecurePackages = ["olm-3.2.16"];

	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	services.logind.settings.Login.HandleLidSwitch = "ignore";

	# ── Networking ──────────────────────────────────────────────────────────────
	networking.hostName = "nixos";
	networking.networkmanager.enable = true;
	networking.nameservers = ["1.1.1.1" "8.8.8.8" "8.8.4.4" "1.0.0.1"];
	networking.resolvconf.enable = true;
	networking.firewall.enable = true;
	networking.firewall.allowedTCPPorts = [8080 5984];

	# ── Locale / keyboard ───────────────────────────────────────────────────────
	time.timeZone = "America/Maceio";

	i18n.defaultLocale = "en_US.UTF-8";
	i18n.extraLocaleSettings = {
		LC_ADDRESS = "pt_BR.UTF-8";
		LC_IDENTIFICATION = "pt_BR.UTF-8";
		LC_MEASUREMENT = "pt_BR.UTF-8";
		LC_MONETARY = "pt_BR.UTF-8";
		LC_NAME = "pt_BR.UTF-8";
		LC_NUMERIC = "pt_BR.UTF-8";
		LC_PAPER = "pt_BR.UTF-8";
		LC_TELEPHONE = "pt_BR.UTF-8";
		LC_TIME = "pt_BR.UTF-8";
	};

	console.keyMap = "br-abnt2";

	# ── Hardware / GPU ──────────────────────────────────────────────────────────
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

	# For mpv hardware decoding
	environment.variables = {
		EDITOR = "nvim";
		LIBVA_DRIVER_NAME = "iHD";
	};

	# ── Users ───────────────────────────────────────────────────────────────────
	users.users.davisvkz = {
		isNormalUser = true;
		description = "Davi Silva Viana";
		extraGroups = ["networkmanager" "wheel" "docker" "libvirtd" "kvm" "vboxusers"];
		shell = pkgs.zsh;
	};

	# ── Programs (system-level) ─────────────────────────────────────────────────
	programs.gnupg.agent = {
		enable = true;
		pinentryPackage = pkgs.pinentry-rofi;
		enableSSHSupport = true;
	};

	programs.zsh.enable = true;

	# ── Packages ────────────────────────────────────────────────────────────────
	environment.systemPackages = with pkgs; [
		home-manager
		qemu
		virt-manager
	];

	# ── Misc ────────────────────────────────────────────────────────────────────
	# Symlink for apps that expect Chrome at a fixed FHS path
	systemd.tmpfiles.rules = [
		"d /opt/google/chrome 0755 root root -"
		"L+ /opt/google/chrome/chrome - - - - ${pkgs.google-chrome}/bin/google-chrome-stable"
	];

	system.stateVersion = "26.05";
}
