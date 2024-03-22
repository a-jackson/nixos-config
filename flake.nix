{
  description = "System config";

  inputs = {
    nixpkgs = { url = "github:NixOS/nixpkgs/nixos-unstable"; };

    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = { url = "github:nix-community/impermanence"; };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
      };
    };

    abe = {
      url = "github:a-jackson/audiobook-extractor";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, impermanence
    , sops-nix, abe, nixvim }@inputs:
    let libx = import ./lib { inherit self inputs; };
    in {
      inherit libx;

      nixosConfigurations = {
        laptop = libx.systemConfig "laptop" "x86_64-linux";
        apps = libx.systemConfig "apps" "x86_64-linux";
        desktop = libx.systemConfig "desktop" "x86_64-linux";
        cloud = libx.systemConfig "cloud" "aarch64-linux";
      };

      homeConfigurations = {
        "andrew@kerberos" = libx.homeConfig "andrew" "kerberos" "x86_64-linux";
        "andrew@desktop" = libx.homeConfig "andrew" "desktop" "x86_64-linux";
        "andrew@work" = libx.homeConfig "andrew" "work" "x86_64-linux";
      };
    };
}
