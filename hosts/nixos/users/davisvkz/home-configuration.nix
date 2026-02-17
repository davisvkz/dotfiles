{
	inputs,
	outputs,
	lib,
	config,
	pkgs,
	...
}: let
	# Construct homeDirectory from username
	homeDir = "/home/davisvkz";
	storePath = "${homeDir}/.password-store";
in {
	nixpkgs.config.allowUnfree = true;
	nix = {package = with pkgs; nix;};
	xdg.enable = true;
	xdg.mime.enable = true;
	imports = [inputs.spicetify-nix.homeManagerModules.default ./hm-programs.nix];

	dconf.enable = true;
	dconf.settings = {
		"org/gnome/desktop/interface" = {color-scheme = "prefer-dark";};
	};

	gtk = {
		enable = true;
		theme = {
			name = "Adwaita-dark";
			package = pkgs.gnome-themes-extra;
		};
		gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
		gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
	};
	qt = {
		enable = true;
		style = {name = "adwaita-dark";};
	};
	#programs.gnupg = {
	#enable = true;
	#enableSSHSupport = true;
	#};
	programs.spicetify = let
		spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
	in {
		enable = true;
		enabledExtensions = with spicePkgs.extensions; [
			adblock
			hidePodcasts
			shuffle # shuffle+ (special characters are sanitized out of extension names)
		];
		enabledCustomApps = with spicePkgs.apps; [newReleases ncsVisualizer];
		enabledSnippets = with spicePkgs.snippets; [rotatingCoverart pointer];

		theme = spicePkgs.themes.catppuccin;
		colorScheme = "mocha";
	};
	programs.gpg = {enable = true;};
	services.gpg-agent = {
		enable = true;
		enableSshSupport = true;
		pinentry = {
			package = pkgs.pinentry-curses;
			#program = pkgs.pinentry;
		};
	};

	home = {
		username = "davisvkz";
		homeDirectory = "/home/davisvkz"; # Required - use --impure
		shellAliases = {magick_cli = "magick";};
		sessionVariables = {NIXPKGS_ALLOW_UNFREE = "1";};
		shell.enableZshIntegration = true;
	};

	home.file.".config/zsh/.zshrc".source = ./config/.zshrc;
	programs.zsh = {
		enable = true;
		dotDir = homeDir;
	};
	programs.password-store = {
		enable = true;
		package =
			pkgs.pass.withExtensions
			(exts: with exts; [pass-otp pass-import pass-audit]);
	};
	services.pass-secret-service = {enable = true;};
	programs.git = {
		enable = true;
		settings.user = {
			email = "davissviana2006@gmail.com";
			name = "davisvkz";
		};
	};
	programs.gh = {
		enable = true;
		gitCredentialHelper = {enable = true;};
	};
	programs.neovim = {
		enable = true;
		extraLuaPackages = ps: [ps.magick];
		extraPackages = [pkgs.imagemagick];
		defaultEditor = true;
		viAlias = true;
		vimAlias = true;
		withNodeJs = true;
		withPython3 = true;
		withRuby = true;
	};

	home.file.".config/nvim" = {
		source = ./config/nvim;
		recursive = true;
	};

	programs.home-manager.enable = true;
	systemd.user.startServices = "sd-switch";
	xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];
	xdg.portal.config.common.default = "gtk";

	services.kdeconnect = {
		enable = true;
		indicator = true;
	};

	home.stateVersion = "26.05";
}
