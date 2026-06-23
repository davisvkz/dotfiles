{
	config,
	lib,
	pkgs,
	flake,
	...
}: let
	cfg = config.profiles.lf;
	lf_dir = "${flake}/hosts/nixos/users/davisvkz/config/lf";
in {
	options.profiles.lf.enable = lib.mkEnableOption "lf file manager";

	config = lib.mkIf cfg.enable {
		home.packages = with pkgs; [
			lf
			(writeShellScriptBin "lfub" (builtins.readFile "${lf_dir}/lfub"))

			# Previewer (scope) dependencies
			bat                  # text / code / json / xml
			mediainfo            # audio / octet-stream + ueberzug fallback
			atool                # archive listings
			odt2txt              # OpenDocument previews
			ffmpegthumbnailer    # video thumbnails
			lynx                 # HTML previews
			pkgs."poppler-utils" # pdftoppm for PDF thumbnails
			imagemagick          # magick for avif / djvu / xcf thumbnails
		];

		xdg.configFile = {
			"lf/lfrc".text = builtins.readFile "${lf_dir}/lfrc";
			"lf/scope" = {
				text = builtins.readFile "${lf_dir}/scope";
				executable = true;
			};
			"lf/cleaner" = {
				text = builtins.readFile "${lf_dir}/cleaner";
				executable = true;
			};
			"lf/icons".text = builtins.readFile "${lf_dir}/icons";
			"lf/shortcutrc".text = builtins.readFile "${lf_dir}/shortcutrc";
		};
	};
}
