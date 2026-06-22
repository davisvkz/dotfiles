{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.dev.docker;
in {
	options.profiles.dev.docker.enable = lib.mkEnableOption "Docker CLI tools (docker, compose, lazydocker)";

	config = lib.mkIf cfg.enable {
		home.packages = with pkgs; [
			docker
			docker-credential-helpers
			lazydocker
			docker-compose
		];
	};
}
