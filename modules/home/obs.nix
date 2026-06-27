{
	config,
	lib,
	...
}: let
	cfg = config.profiles.obs;
in {
	options.profiles.obs.enable =
		lib.mkEnableOption "OBS Studio (com câmera virtual via v4l2loopback do sistema)";

	config = lib.mkIf cfg.enable {
		programs.obs-studio = {
			enable = true;
			# Câmera virtual provida pelo v4l2loopback configurado em modules/nixos/media.nix
			# (/dev/video2 = "OBS Virtual Camera", exclusive_caps=1). Sem plugins extras.
			plugins = [];
		};
	};
}
