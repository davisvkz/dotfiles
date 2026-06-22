{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.devtools;
in {
	options.profiles.devtools.enable = lib.mkEnableOption "Developer tools (nix-ld, PostgreSQL, mtr)";

	config = lib.mkIf cfg.enable {
		programs.nix-ld = {
			enable = true;
			libraries = with pkgs; [
				typst
				nodejs
				glib
				glibc
				nss
				nspr
				systemd
				libsecret
				libnotify
				libGL
				vulkan-loader
				zlib
				at-spi2-atk
				at-spi2-core
				cups
				dbus
				expat
				libdrm
				libgbm
				mesa
				libxkbcommon
				pango
				cairo
				alsa-lib
				gtk3
				gdk-pixbuf
				atk
				fontconfig
				freetype
				openssl
				prisma-engines
				# X11 libraries (top-level names, nixpkgs-unstable)
				libx11
				libxcomposite
				libxdamage
				libxext
				libxfixes
				libxrandr
				libxrender
				libxcb
				libxscrnsaver
				libxtst
				libxi
				libxcursor
				libxshmfence
			];
		};

		programs.mtr.enable = true;

		services.postgresql = {
			enable = true;
			package = pkgs.postgresql;
			authentication = pkgs.lib.mkForce ''
				# TYPE  DATABASE        USER            ADDRESS                 METHOD
				local   all             all                                     trust
			'';
		};
	};
}
