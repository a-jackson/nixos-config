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
      };
    };

    abe = {
      url = "github:a-jackson/audiobook-extractor";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      ...
    }@inputs:
    let
      libx = import ./lib { inherit inputs; };
    in
    {
      inherit libx;

      nixosConfigurations = {
        laptop = libx.mkSystem {
          hostname = "laptop";
          desktop = "gnome";
        };
        apps = libx.mkSystem { hostname = "apps"; };
        desktop = libx.mkSystem {
          hostname = "desktop";
          desktop = "gnome";
        };
        cloud = libx.mkSystem {
          hostname = "cloud";
          system = "aarch64-linux";
        };
        nas = libx.mkSystem { hostname = "nas"; };
      };

      homeConfigurations = {
        "andrew@work" = libx.mkHome { type = "work"; };
      };
    };
}
