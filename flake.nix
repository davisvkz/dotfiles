{
	description = "My Nixos configuration";
	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
		nixpkgs-stable.url = "https://flakehub.com/f/NixOS/nixpkgs/*.tar.gz";
		nixcord.url = "github:kaylorben/nixcord";
		nur = {
			url = "github:nix-community/NUR";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		nix-snapd = {
			url = "github:nix-community/nix-snapd";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		nix-on-droid = {
			url = "github:nix-community/nix-on-droid/release-24.05";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		spicetify-nix = {
			url = "github:Gerg-L/spicetify-nix";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		home-manager = {
			url = "github:nix-community/home-manager/master";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		llm-agents = {
			url = "github:numtide/llm-agents.nix";
		};

		winapps.url = "github:winapps-org/winapps";
		winapps.inputs.nixpkgs.follows = "nixpkgs";

		blueprint.url = "github:numtide/blueprint";
		blueprint.inputs.nixpkgs.follows = "nixpkgs";
	};

	outputs = inputs:
		inputs.blueprint {
			inherit inputs;
		};
}
