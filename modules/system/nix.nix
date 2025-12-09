{
	config,
	inputs,
	...
}: {
	nixpkgs.config.allowUnfree = true;
	nixpkgs.overlays = [
		(final: prev: {
				stable =
					import inputs.nixpkgs-stable {
						inherit (final) system;
						config.allowUnfree = true;
					};
			})
	];
}
