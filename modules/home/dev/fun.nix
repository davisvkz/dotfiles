{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.dev.fun;
in {
	options.profiles.dev.fun.enable = lib.mkEnableOption "Fun / educational computing (CraftOS-PC, CCEmuX)";

	config = lib.mkIf cfg.enable {
		home.packages = with pkgs; [
			ccemux
			(lib.lowPrio craftos-pc)
		];
	};
}
