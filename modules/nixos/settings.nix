{
	config,
	lib,
	flake,
	hostName,
	...
}: {
	options.settings =
		lib.mkOption {
			type = lib.types.anything;
			default = flake.lib.settings;
			description = "Centralized identity, DNS and theme settings (source: lib/settings.nix)";
		};

	config = {
		networking.hostName = lib.mkDefault hostName;

		time.timeZone = lib.mkDefault config.settings.identity.timezone;

		i18n.defaultLocale = lib.mkDefault config.settings.identity.locale.default;
		i18n.extraLocaleSettings =
			lib.mkDefault (
				let
					extra = config.settings.identity.locale.extra;
				in {
					LC_ADDRESS = extra;
					LC_IDENTIFICATION = extra;
					LC_MEASUREMENT = extra;
					LC_MONETARY = extra;
					LC_NAME = extra;
					LC_NUMERIC = extra;
					LC_PAPER = extra;
					LC_TELEPHONE = extra;
					LC_TIME = extra;
				}
			);

		console.keyMap = lib.mkDefault config.settings.identity.keyboard.console;
	};
}
