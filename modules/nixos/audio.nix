{
	config,
	lib,
	...
}: let
	cfg = config.profiles.audio;
in {
	options.profiles.audio.enable = lib.mkEnableOption "Audio (PipeWire + rtkit)";

	config =
		lib.mkIf cfg.enable {
			security.rtkit.enable = true;
			services.pipewire = {
				enable = true;
				alsa.enable = true;
				pulse.enable = true;
				wireplumber.enable = true;
			};
		};
}
