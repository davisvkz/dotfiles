{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.dev.dotnet;
in {
	options.profiles.dev.dotnet.enable = lib.mkEnableOption ".NET / C# (SDK 10, OmniSharp, Mono, Rider)";

	config =
		lib.mkIf cfg.enable {
			home.sessionVariables = {
				OMNISHARP_MONO = "${pkgs.mono}/bin/mono";
			};

			home.packages = with pkgs; [
				dotnet-sdk_10
				omnisharp-roslyn
				mono
				netcoredbg
				csharpier
				jetbrains.rider
				jetbrains-toolbox
			];
		};
}
