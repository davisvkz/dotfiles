{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.media;
in {
	options.profiles.media.enable =
		lib.mkEnableOption "Media (v4l2loopback / OBS virtual camera)";

	config = lib.mkIf cfg.enable {
		boot.extraModulePackages = [config.boot.kernelPackages.v4l2loopback];
		boot.kernelModules = ["v4l2loopback"];
		boot.extraModprobeConfig = ''
			options v4l2loopback devices=2 video_nr=2,3 card_label="OBS Virtual Camera","Waydroid Camera" exclusive_caps=1,1
		'';

		# ── Waydroid camera bridge (on-demand) ──────────────────────────────────
		# Feeds the real webcam (/dev/video0) into the Waydroid loopback device
		# (/dev/video3) via ffmpeg. No wantedBy = manual start only.
		# Usage: waydroid-camera start | stop
		systemd.services.waydroid-camera = lib.mkIf config.virtualisation.waydroid.enable {
			description = "Bridge real webcam (/dev/video0) -> Waydroid loopback (/dev/video3)";
			serviceConfig = {
				ExecStart = "${pkgs.ffmpeg}/bin/ffmpeg -f v4l2 -input_format yuyv422 -framerate 30 -video_size 640x480 -i /dev/video0 -pix_fmt yuyv422 -f v4l2 /dev/video3";
				Restart = "on-failure";
			};
		};

		environment.systemPackages = lib.mkIf config.virtualisation.waydroid.enable [
			(pkgs.writeShellScriptBin "waydroid-camera" ''
				case "$1" in
					start) sudo systemctl start  waydroid-camera ;;
					stop)  sudo systemctl stop   waydroid-camera ;;
					*)     echo "uso: waydroid-camera {start|stop}" ;;
				esac
			'')
		];
	};
}
