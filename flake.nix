{
  description = "System config";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";

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

    abe = {
      url = "github:a-jackson/audiobook-extractor";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-stable,
      home-manager,
      impermanence,
      sops-nix,
      abe,
      nixvim,
      nixos-generators,
      stylix,
    }@inputs:
    let
      libx = import ./lib { inherit self inputs; };
    in
    {
      inherit libx;

      nixosConfigurations = {
        laptop = libx.mkSystem {
          hostname = "laptop";
          desktop = "hyprland";
        };
        apps = libx.mkSystem { hostname = "apps"; };
        desktop = libx.mkSystem {
          hostname = "desktop";
          desktop = "plasma";
        };
        cloud = libx.mkSystem {
          hostname = "cloud";
          system = "aarch64-linux";
        };
        nas = libx.mkSystem { hostname = "nas"; };
      };

      homeConfigurations = {
        "andrew@laptop" = libx.mkHome { type = "hyprland"; };
        "andrew@desktop" = libx.mkHome { type = "plasma"; };
        "andrew@work" = libx.mkHome { type = "work"; };
        "andrew@apps" = libx.mkHome;
        "andrew@nas" = libx.mkHome;
        "andrew@cloud" = libx.mkHome { system = "aarch64-linux"; };
      };

      imageConfigurations = {
        "iso" = libx.mkImage { hostname = "iso"; };
      };

      devShells = libx.forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
              btrfs-progs
              git
              nix
              nixfmt-rfc-style
              parted
              sops
              ssh-to-age
              vim
              xfsprogs
            ];
          };
        }
      );
    };
}
