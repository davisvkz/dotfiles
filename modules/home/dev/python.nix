{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.dev.python;
in {
	options.profiles.dev.python.enable = lib.mkEnableOption "Python development (uv, pipx, Python 3)";

	config = lib.mkIf cfg.enable {
		home.packages = with pkgs; [
			uv
			pipx
			(python3.withPackages (ps:
				with ps; [
					pygobject3
					pycairo
					opencv4
				]))
		];
	};
}
