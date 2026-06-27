{
	config,
	lib,
	pkgs,
	flake,
	...
}: let
	cfg = config.profiles.mpv;
	mpv_dir = "${flake}/dotfiles/mpv";
in {
	options.profiles.mpv.enable = lib.mkEnableOption "mpv media player";

	config = lib.mkIf cfg.enable {
		programs.mpv = {
			enable = true;

			config = {
				# GPU / rendering
				"gpu-context" = "x11egl";
				"gpu-api" = "opengl";
				hwdec = "no";
				framedrop = "vo";
				"video-sync" = "display-resample";
				"demuxer-thread" = "yes";

				# Screenshots: <timestamp> - <video name>
				"screenshot-template" = "%F.%P";
			};

			bindings = {
				"}" = "add speed -0.01";
				"{" = "add speed 0.01";
				"]" = "add speed -0.1";
				"[" = "add speed 0.1";
				k = ''no-osd cycle-values glsl-shaders "~~/shaders/invert.glsl" "" ; show-text "Invert Shader"'';
				"alt+a" = "vf toggle negate";
				"alt+b" = "set contrast -35";
				"alt+h" = ''cycle-values hwdec auto-safe no ; show-text "HWDEC: ''${hwdec}"'';
				"alt+i" = ''cycle-values interpolation yes no ; show-text "Interp: ''${interpolation}"'';
			};
		};

		# Custom script and shader files
		xdg.configFile = {
			"mpv/scripts/slicing_copy.lua".source = "${mpv_dir}/scripts/slicing_copy.lua";
			"mpv/shaders/invert.glsl".source = "${mpv_dir}/shaders/invert.glsl";
		};
	};
}
