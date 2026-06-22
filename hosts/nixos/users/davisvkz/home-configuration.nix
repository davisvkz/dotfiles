{
	inputs,
	pkgs,
	lib,
	flake,
	osConfig,
	...
}: {
	imports = [
		inputs.spicetify-nix.homeManagerModules.default
		"${flake}/modules/home/all.nix"
	];

	# ── Profiles ────────────────────────────────────────────────────────────────
	profiles = {
		cli.enable = true;
		dev = {
			core.enable = true;
			js.enable = true;
			python.enable = true;
			rust.enable = true;
			go.enable = true;
			dotnet.enable = true;
			jvm.enable = true;
			cpp.enable = true;
			lua.enable = true;
			db.enable = true;
			docker.enable = true;
			http.enable = true;
			web.enable = true;
			infra.enable = true;
			fun.enable = true;
		};
		gaming.enable = true;
		media.enable = true;
		security.enable = true;
		latex.enable = true;
		chat.enable = true;
		browsers.enable = true;
		desktop.enable = true;
		apps = {
			enable = true;
			winapps.enable = true;
		};
		theme.enable = true;
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
		shellAliases = {magick_cli = "magick";};
		shell.enableZshIntegration = true;
		sessionVariables = {
			PLANTUML_JAR = "${pkgs.plantuml}/lib/plantuml.jar";
		};
	};

	# ── Shell ───────────────────────────────────────────────────────────────────
	programs.zsh = {
		enable = true;
		# dotDir não sobrescrito: com xdg.enable + stateVersion 26.05 o default
		# é ~/.config/zsh, fazendo o HM exportar ZDOTDIR de forma confiável.
		initContent = lib.mkAfter (builtins.readFile ./config/.zshrc);
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
		colorScheme = osConfig.settings.theme.spicetifyScheme;
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
			email = osConfig.settings.identity.email;
			name = osConfig.settings.identity.username;
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

	# ── Misc ────────────────────────────────────────────────────────────────────
	programs.home-manager.enable = true;
	systemd.user.startServices = "sd-switch";

	home.stateVersion = "26.05";
}
