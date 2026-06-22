{
	description = "My Nixos configuration";
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

		spicetify-nix = {
			url = "github:Gerg-L/spicetify-nix";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		home-manager = {
			url = "github:nix-community/home-manager/master";
			inputs.nixpkgs.follows = "nixpkgs";
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
		};
}
