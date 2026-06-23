{flake, ...}: {
	imports = ["${flake}/modules/home/all.nix"];

	# ── Profiles ────────────────────────────────────────────────────────────────
	profiles = {
		cli.enable = true;
		lf.enable = true;
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
		spicetify.enable = true;
		secrets.enable = true;
		git.enable = true;
		neovim.enable = true;
		xdg.enable = true;
		kdeconnect.enable = true;
		shell.enable = true;
	};

	# ── Misc ────────────────────────────────────────────────────────────────────
	programs.home-manager.enable = true;
	systemd.user.startServices = "sd-switch";
	home.stateVersion = "26.05";
}
