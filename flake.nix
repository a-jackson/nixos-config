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

    leng = {
      url = "github:cottand/leng";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = { self, nixpkgs, home-manager, impermanence, sops-nix, leng }@inputs:
    let
      systemConfig = hostname: system: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = inputs;
        modules = [
          ./${hostname}.nix
          ./hardware/${hostname}.nix
          {
            networking.hostName = hostname;
          }
        ];
      };
      homeConfig = username: hostname: system: home-manager.lib.homeManagerConfiguration {
        modules = [
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
          pkgs = import nixpkgs {
            inherit system overlays;
          };
          buildInputs = with pkgs; [
            sops
            ssh-to-age
            gnupg
            pinentry
          ];
        in
        with pkgs;
        {
          default = mkShell {
            inherit buildInputs;
          };
        }
      );
    in
    {
      nixosConfigurations = {
        kerberos = systemConfig "kerberos" "x86_64-linux";
        server = systemConfig "server" "x86_64-linux";
        apps = systemConfig "apps" "x86_64-linux";
        desktop = systemConfig "desktop" "x86_64-linux";
      };

      homeConfigurations = {
        "andrew@kerberos" = homeConfig "andrew" "kerberos" "x86_64-linux";
        "andrew@desktop" = homeConfig "andrew" "desktop" "x86_64-linux";
        "andrew@work" = homeConfig "andrew" "work" "x86_64-linux";
      };

      devShells.x86_64-linux = shell "x86_64-linux";
    };
}
