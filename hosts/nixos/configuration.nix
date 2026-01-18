{pkgs, ...}: {
	services.logind.lidSwitch = "ignore";
	services.picom = {
		enable = true;
		backend = "glx";
	};
	programs.nix-ld.enable = true;

	programs.nix-ld.libraries = with pkgs; [
		nodejs
	];
	programs.light.enable = true;
	programs.gnupg.agent = {
		enable = true;
		enableSSHSupport = true;
	};
	programs.steam = {
		enable = true;
		remotePlay.openFirewall =
			true; # Open ports in the firewall for Steam Remote Play
		dedicatedServer.openFirewall =
			true; # Open ports in the firewall for Source Dedicated Server
		localNetworkGameTransfers.openFirewall =
			true; # Open ports in the firewall for Steam Local Network Game Transfers
	};
	services.locate.enable = true;
	services.locate.locate = pkgs.plocate;
	virtualisation.waydroid.enable = true;
	services.flatpak.enable = true;
	xdg.portal.enable = true;
	xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
	xdg.portal.config.common.default = "gtk";
	hardware.bluetooth.enable = true;
	services.blueman.enable = true;

	virtualisation = {
		libvirtd = {
			qemu = {
				package = pkgs.qemu_kvm; # only emulates host arch, smaller download
				swtpm.enable = true; # allows for creating emulated TPM
				ovmf.packages = [
					(pkgs.OVMF.override {
							secureBoot = true;
							tpmSupport = true;
						}).fd
				]; # or use pkgs.OVMFFull.fd, which enables more stuff
			};
		};
		docker = {
			daemon.settings = {
				dns = ["1.1.1.1" "8.8.8.8" "1.0.0.1" "8.8.4.4"];
			};
			enable = true;
			#rootless = {
			#enable = true;
			#setSocketVariable = true;
			#};
		};
	};

	programs.mtr.enable = true;
	fonts.fontconfig.defaultFonts = {
		sansSerif = ["Noto Sans CJK SC" "Noto Color Emoji" "Fira Code Nerd Font" "Material Design Icons Desktop"];
		serif = ["Merriweather" "Fira Code Nerd Font" "Noto Color Emoji" "Material Design Icons Desktop"];
		monospace = ["Fira Code Nerd Font" "Noto Color Emoji" "Material Design Icons Desktop"];
		emoji = ["Noto Color Emoji" "Material Design Icons Desktop"];
	};
	fonts.packages = with pkgs; [
		freefont_ttf
		freetype
		merriweather
		noto-fonts
		noto-fonts-color-emoji
		noto-fonts-cjk-sans
		liberation_ttf
		fira-code
		fira-code-symbols
		mplus-outline-fonts.githubRelease
		dina-font
		proggyfonts
		nerd-fonts.fira-code
		nerd-fonts.droid-sans-mono
	];

	imports = [
		./hardware-configuration.nix
		./programs.nix
		#      ./my-hardware.nix
		./imports.nix
	];

	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	networking.hostName = "nixos";
	networking.networkmanager.enable = true;
	networking.nameservers = ["1.1.1.1" "8.8.8.8" "8.8.4.4" "1.0.0.1"];
	networking.resolvconf.enable = true;

	environment.variables.EDITOR = "neovim";

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

	services.xserver.xkb = {
		layout = "br";
		variant = "";
	};
	services.gvfs.enable = true;

	console.keyMap = "br-abnt2";

	users.users.davisvkz = {
		isNormalUser = true;
		description = "Davi Silva Viana";
		extraGroups = ["networkmanager" "wheel" "docker" "libvirtd" "kvm"];
		shell = pkgs.zsh;
	};

	services.displayManager.sddm = {enable = true;};
	services.xserver = {
		enable = true;
		windowManager.bspwm = {
			enable = true;
			configFile = "/home/davisvkz/.config/bspwm/bspwmrc";
			sxhkd.configFile = "/home/davisvkz/.config/sxhkd/sxhkdrc";
		};
	};
	nix.settings.experimental-features = ["nix-command" "flakes"];

	nixpkgs.config.allowUnfree = true;

	environment.systemPackages = with pkgs; [
		neovim
		git
		wget
		polybar
		lf
		nixd
		imagemagick
		home-manager
		alsa-lib
		alsa-lib.dev
		qemu
		virt-manager
	];

	system.stateVersion = "25.05";
	networking.firewall.enable = false;
}
