{
	inputs,
	pkgs,
	flake,
	...
}: let
	homeDir = "/home/davisvkz";
in {
	imports = [
		inputs.spicetify-nix.homeManagerModules.default
		"${flake}/modules/home/all.nix"
	];

	# ── Profiles ────────────────────────────────────────────────────────────────
	profiles = {
		cli.enable = true;
		dev.enable = true;
		gaming.enable = true;
		media.enable = true;
		security.enable = true;
		latex.enable = true;
		chat.enable = true;
		browsers.enable = true;
		desktop.enable = true;
		apps.enable = true;
	};

	# ── XDG ─────────────────────────────────────────────────────────────────────
	xdg = {
		enable = true;
		desktopEntries = {
			firefox = {
				name = "firefox";
				exec = "${pkgs.firefox}/bin/firefox";
			};
			roblox = {
				name = "roblox";
				exec = "/var/lib/flatpak/app/org.vinegarhq.Sober/current/active/export/bin/org.vinegarhq.Sober";
			};
		};
		mimeApps = {
			enable = true;
			defaultApplications = {
				"application/pdf" = "org.pwmt.zathura.desktop";
				"text/html" = "firefox.desktop";
				"text/xml" = "firefox.desktop";
				"x-scheme-handler/http" = "firefox.desktop";
				"x-scheme-handler/https" = "firefox.desktop";
				"x-scheme-handler/about" = "firefox.desktop";
				"x-scheme-handler/unknown" = "firefox.desktop";
				"x-scheme-handler/roblox-player" = "roblox.desktop";
			};
		};
	};

	# ── Identity ────────────────────────────────────────────────────────────────
	home = {
		username = "davisvkz";
		homeDirectory = homeDir; # Required - use --impure
		shellAliases = {magick_cli = "magick";};
		shell.enableZshIntegration = true;
		sessionVariables = {
			PLANTUML_JAR = "${pkgs.plantuml}/lib/plantuml.jar";
			PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
			PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
			PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "1";
		};
	};

	# ── Shell ───────────────────────────────────────────────────────────────────
	home.file.".config/zsh/.zshrc".source = ./config/.zshrc;
	programs.zsh = {
		enable = true;
		dotDir = homeDir;
	};

	# ── Spicetify ───────────────────────────────────────────────────────────────
	programs.spicetify = let
		spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
	in {
		enable = true;
		enabledExtensions = with spicePkgs.extensions; [
			adblock
			hidePodcasts
			shuffle
		];
		enabledCustomApps = with spicePkgs.apps; [newReleases ncsVisualizer];
		enabledSnippets = with spicePkgs.snippets; [rotatingCoverart pointer];
		theme = spicePkgs.themes.catppuccin;
		colorScheme = "mocha";
	};

	# ── GPG ─────────────────────────────────────────────────────────────────────
	programs.gpg = {enable = true;};
	services.gpg-agent = {
		enable = true;
		enableSshSupport = true;
		pinentry = {package = pkgs.pinentry-rofi;};
	};

	# ── Password store ──────────────────────────────────────────────────────────
	programs.password-store = {
		enable = true;
		package =
			pkgs.pass.withExtensions
			(exts: with exts; [pass-otp pass-import pass-audit]);
	};
	services.pass-secret-service = {enable = true;};

	# ── Git ─────────────────────────────────────────────────────────────────────
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

	# ── Neovim ──────────────────────────────────────────────────────────────────
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

	# ── KDE Connect ─────────────────────────────────────────────────────────────
	services.kdeconnect = {
		enable = true;
		indicator = true;
	};

	# ── Playwright browser cache ─────────────────────────────────────────────────
	home.file.".cache/ms-playwright".source = pkgs.playwright-driver.browsers;

	# ── WinApps ─────────────────────────────────────────────────────────────────
	home.packages = [
		inputs.winapps.packages.${pkgs.system}.winapps
		inputs.winapps.packages.${pkgs.system}.winapps-launcher
	];

	# ── Misc ────────────────────────────────────────────────────────────────────
	programs.home-manager.enable = true;
	systemd.user.startServices = "sd-switch";

	home.stateVersion = "26.05";
}
