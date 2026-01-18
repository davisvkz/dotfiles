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
	};

	outputs = {
		self,
		nixpkgs,
		nixpkgs-stable,
		home-manager,
		nur,
		nix-snapd,
		...
	} @ inputs: let
		inherit (self) outputs;
		system = "x86_64-linux";
		pkgs = nixpkgs.legacyPackages.${system};
		pkgs-stable = nixpkgs-stable.legacyPackages.${system};
		inherit (nixpkgs);
		username = "davisvkz";
	in {
		nixosConfigurations = {
			nixos =
				nixpkgs.lib.nixosSystem {
					specialArgs = {inherit inputs outputs pkgs pkgs-stable system username;};
					modules = [
						./hosts/nixos/configuration.nix
						nur.modules.nixos.default
						nix-snapd.nixosModules.default
						{
							services.snap.enable = true;
						}
					];
				};
		};

		homeConfigurations = {
			${username} =
				home-manager.lib.homeManagerConfiguration {
					pkgs = nixpkgs.legacyPackages.${system};
					extraSpecialArgs = {inherit inputs outputs pkgs pkgs-stable system username;};
					modules = [
						./hosts/nixos/home.nix
					];
				};
		};
	};
}
