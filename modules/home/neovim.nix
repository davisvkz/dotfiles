{
	config,
	lib,
	pkgs,
	flake,
	...
}: let
	cfg = config.profiles.neovim;
in {
	options.profiles.neovim.enable = lib.mkEnableOption "Neovim editor with Lua config";

	config =
		lib.mkIf cfg.enable {
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
				source = "${flake}/hosts/nixos/users/davisvkz/config/nvim";
				recursive = true;
			};
		};
}
