{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.dev.android;
in {
	options.profiles.dev.android.enable = lib.mkEnableOption "Android Studio (SDK gerenciado pelo Studio)";

	config =
		lib.mkIf cfg.enable {
			home.packages = with pkgs; [
				android-studio
			];
		};
}
