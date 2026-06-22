{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.dev.js;
in {
	options.profiles.dev.js.enable = lib.mkEnableOption "JavaScript / TypeScript (Node.js, pnpm, Bun, Deno, Biome)";

	config = lib.mkIf cfg.enable {
		home.packages = with pkgs; [
			nodejs
			pnpm
			bun
			deno
			biome
		];
	};
}
