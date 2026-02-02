{
	config,
	lib,
	pkgs,
	...
}: {
	services.picom.enable = true;
	programs.zsh.enable = true;
	services.displayManager.sddm = {enable = true;};
	programs.nix-ld.enable = true;

	programs.nix-ld.libraries = with pkgs; [
		nodejs
		glib
		gtk3
		pango
		freetype
		fontconfig
		dbus
		libxkbcommon
		libdrm
		mesa
		libgbm
		xorg.libxcb
		xorg.libX11
		xorg.libXcomposite
		xorg.libXdamage
		xorg.libXrandr
		xorg.libXext
		xorg.libXi
		xorg.libXcursor
		xorg.libXfixes
		xorg.libXrender
		xorg.libXtst
		xorg.libXScrnSaver
		nss
		nspr
		alsa-lib
		atk
		cups
		expat
	];
	services.xserver = {
		enable = true;
		windowManager.bspwm = {
			enable = true;
			configFile = "/home/davisvkz/.config/bspwm/bspwmrc";
			sxhkd.configFile = "/home/davisvkz/.config/sxhkd/sxhkdrc";
		};
	};
}
