{
	config,
	lib,
	pkgs,
	flake,
	...
}: let
	cfg = config.profiles.lf;
	lf_dir = "${flake}/dotfiles/lf";
in {
	options.profiles.lf.enable = lib.mkEnableOption "lf file manager";

	config = lib.mkIf cfg.enable {
		programs.lf = {
			enable = true;
			# lfrc gerenciado pelo módulo — não duplicar em xdg.configFile
			extraConfig = builtins.readFile "${lf_dir}/lfrc";
		};

		home.packages = with pkgs; [
			(writeShellScriptBin "lfub" (builtins.readFile "${lf_dir}/lfub"))

			# Dependências do previewer (scope)
			bat                  # text / code / json / xml
			mediainfo            # audio / octet-stream + ueberzug fallback
			atool                # archive listings
			odt2txt              # OpenDocument previews
			ffmpegthumbnailer    # video thumbnails
			lynx                 # HTML previews
			pkgs."poppler-utils" # pdftoppm para thumbnails de PDF
			imagemagick          # magick para avif / djvu / xcf
		];

		xdg.configFile = {
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
