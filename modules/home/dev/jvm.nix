{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.dev.jvm;
in {
	options.profiles.dev.jvm.enable = lib.mkEnableOption "JVM development (JDK 25)";

	config = lib.mkIf cfg.enable {
		home.packages = with pkgs; [
			jdk25
		];
	};
}
