{
	description = "My Nixos configuration";
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

		spicetify-nix = {
			url = "github:Gerg-L/spicetify-nix";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		home-manager = {
			url = "github:nix-community/home-manager/master";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		nix-on-droid = {
			url = "github:nix-community/nix-on-droid/release-24.05";
			inputs.nixpkgs.follows = "nixpkgs";
			inputs.home-manager.follows = "home-manager";
		};

		winapps = {
			url = "github:winapps-org/winapps";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		blueprint.url = "github:numtide/blueprint";
		blueprint.inputs.nixpkgs.follows = "nixpkgs";
	};

	outputs = inputs:
		inputs.blueprint {
			inherit inputs;
			nixpkgs.config = {
				allowUnfree = true;
				permittedInsecurePackages = ["olm-3.2.16"];
			};
		};
}
