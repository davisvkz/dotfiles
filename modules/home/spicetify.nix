{
	config,
	lib,
	pkgs,
	inputs,
	osConfig,
	...
}: let
	cfg = config.profiles.spicetify;
	spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in {
	imports = [inputs.spicetify-nix.homeManagerModules.default];

	options.profiles.spicetify.enable = lib.mkEnableOption "Spicetify (Spotify theming)";

	config =
		lib.mkIf cfg.enable {
			programs.spicetify = {
				enable = true;
				enabledExtensions = with spicePkgs.extensions; [
					adblock
					hidePodcasts
					shuffle
				];
				enabledCustomApps = with spicePkgs.apps; [newReleases ncsVisualizer];
				enabledSnippets = with spicePkgs.snippets; [rotatingCoverart pointer];
				theme = spicePkgs.themes.${osConfig.settings.theme.spicetifyTheme};
				colorScheme = osConfig.settings.theme.spicetifyScheme;
			};
		};
}
