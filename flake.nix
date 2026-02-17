{
	description = "My Nixos configuration";
	inputs = {
		nix-snapd = {
			url = "github:nix-community/nix-snapd";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
		nixpkgs-stable.url = "https://flakehub.com/f/NixOS/nixpkgs/*.tar.gz";
		nixcord.url = "github:kaylorben/nixcord";
		nur = {
			url = "github:nix-community/NUR";
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
		blueprint.url = "github:numtide/blueprint";
		blueprint.inputs.nixpkgs.follows = "nixpkgs";
	};

	outputs =
		inputs : inputs.blueprint {
			inherit inputs;
		};
}
