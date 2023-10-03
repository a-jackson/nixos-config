{
  description = "System config";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
      };
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
        kerberos = systemConfig "kerberos";
        server = systemConfig "server";
      };
    };
}
