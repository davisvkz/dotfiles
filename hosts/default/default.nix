# Blueprint host loader para nix-on-droid (Android).
# Blueprint detecta este arquivo via hosts/<nome>/default.nix e chama
# `import path { inherit flake inputs hostName; }` esperando { class; value; }.
{ flake, inputs, ... }: {
	class = "nix-on-droid";
	value = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
		pkgs = import inputs.nixpkgs {
			system = "aarch64-linux";
			config = {
				allowUnfree = true;
				permittedInsecurePackages = ["olm-3.2.16"];
			};
		};
		home-manager-path = inputs.home-manager.outPath;
		extraSpecialArgs = { inherit flake inputs; };
		modules = [ ./droid-configuration.nix ];
	};
}
