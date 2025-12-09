{
	nixpkgs.config.allowUnfree = true;
	home.sessionVariables = {
		NIXPKGS_ALLOW_UNFREE = "1";
	};
	imports = [
	../../hm-modules/programs/all.nix
	];
}
