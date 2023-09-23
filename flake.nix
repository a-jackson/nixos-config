{
  description = "System config";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/release-23.05";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
    };
  };

  outputs = { self, nixpkgs, home-manager, impermanence, sops-nix }@inputs:
    let
      systemConfig = hostname: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = inputs;
        modules = [
          ./${hostname}.nix
          ./hardware/${hostname}.nix
          {
            networking.hostName = hostname;
          }
        ];
      };
    in
    {
      nixosConfigurations = {
        laptop = systemConfig "laptop";
      };
    };
}
