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
			android.enable = true;
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
		# CLI / TUI tools
		tmux.enable = true;
		btop.enable = true;
		mpv.enable = true;
		zathura.enable = true;
		newsboat.enable = true;
		wezterm.enable = true;
		# Desktop / WM
		rofi.enable = true;
		bspwm.enable = true;
		sxhkd.enable = true;
		polybar.enable = true;
		wmX11.enable = true;
	};

	# ── Misc ────────────────────────────────────────────────────────────────────
	programs.home-manager.enable = true;
	systemd.user.startServices = "sd-switch";
	home.stateVersion = "26.05";
}
