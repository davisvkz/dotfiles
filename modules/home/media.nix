{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.media;
in {
	options.profiles.media.enable = lib.mkEnableOption "Media, creative and screenshot tools";

	config =
		lib.mkIf cfg.enable {
			home.packages = with pkgs; [
				# Vídeo / áudio
				mpv
				vlc
				ffmpeg-full
				sox
				gst_all_1.gstreamer
				mpdris2

				# Streaming / gravação
				obs-studio
				obs-do
				obs-cli
				obs-cmd

				# Criação visual
				gimp3
				blender
				kdePackages.kdenlive
				aseprite
				tiled
				fritzing

				# Downloads de mídia
				yt-dlp
				gallery-dl

				# Música / áudio
				ytmdesktop
				songrec
				whisperx
				openai-whisper
				voxinput
				espeak
				speechd

				# Screenshots
				shutter
				ksnip
				scrot
				qimgv

				# Rename/wrap de binário
				(symlinkJoin {
						name = "gplay";
						paths = [pkgs.play];
						postBuild = ''
							rm $out/bin/play
						'';
					})
			];
		};
}
