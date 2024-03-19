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
    let
      systemConfig = hostname: system:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = inputs;
          modules = [ ./hosts/${hostname} { networking.hostName = hostname; } ];
        };
      homeConfig = username: hostname: system:
        home-manager.lib.homeManagerConfiguration {
          modules = [
            { imports = [ nixvim.homeManagerModules.nixvim ]; }
            ./home/${hostname}.nix
            {
              home = {
                username = nixpkgs.lib.mkDefault "${username}";
                homeDirectory = nixpkgs.lib.mkDefault "/home/${username}";
                stateVersion = "23.05";
              };
            }
          ];
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit inputs; };
        };
      shell = (system:
        let
          overlays = [ ];
          pkgs = import nixpkgs { inherit system overlays; };
          buildInputs = with pkgs; [ sops ssh-to-age gnupg pinentry ];
        in with pkgs; { default = mkShell { inherit buildInputs; }; });
    in {
      nixosConfigurations = {
        laptop = systemConfig "laptop" "x86_64-linux";
        apps = systemConfig "apps" "x86_64-linux";
        desktop = systemConfig "desktop" "x86_64-linux";
        cloud = systemConfig "cloud" "aarch64-linux";
      };

      homeConfigurations = {
        "andrew@kerberos" = homeConfig "andrew" "kerberos" "x86_64-linux";
        "andrew@desktop" = homeConfig "andrew" "desktop" "x86_64-linux";
        "andrew@work" = homeConfig "andrew" "work" "x86_64-linux";
      };

      devShells.x86_64-linux = shell "x86_64-linux";
    };
}
