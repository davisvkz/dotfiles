{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.dev.lua;
in {
	options.profiles.dev.lua.enable = lib.mkEnableOption "Lua development and Neovim image support (magick)";

	config = lib.mkIf cfg.enable {
		home.packages = with pkgs; [
			(lua5_1.withPackages (ps: with ps; [luarocks]))
			imagemagick
			luajitPackages.magick
		];
	};
}
