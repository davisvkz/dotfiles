{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.latex;
in {
	options.profiles.latex.enable = lib.mkEnableOption "LaTeX, Typst and document tools";

	config =
		lib.mkIf cfg.enable {
			home.packages = with pkgs; [
				# LaTeX
				texliveFull
				texstudio
				texmaker

				# Typst
				typst
				tinymist

				# Alternativas
				tectonic

				# Conversão / diagrama
				pandoc
				pandoc-plantuml-filter
				plantuml-c4
				graphviz

				# PDF
				poppler-utils
			];
		};
}
