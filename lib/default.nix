{ self, inputs }:
let
  inherit (inputs)
    nixpkgs
    home-manager
    nixvim
    nixos-generators
    ;
in
{
  mkSystem =
    {
      hostname,
      system ? "x86_64-linux",
      username ? "andrew",
      desktop ? null,
    }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = inputs // {
        inherit username hostname desktop;
      };
      modules = [ ../hosts ];
    };

  mkHome =
    {
      type ? "headless",
      username ? "andrew",
      system ? "x86_64-linux",
    }:
    home-manager.lib.homeManagerConfiguration {
      modules = [
        { imports = [ nixvim.homeManagerModules.nixvim ]; }
        ../home/${type}.nix
        {
          home = {
            username = nixpkgs.lib.mkDefault "${username}";
            homeDirectory = nixpkgs.lib.mkDefault "/home/${username}";
            stateVersion = "23.05";
          };
        }
      ];
      pkgs = nixpkgs.legacyPackages.${system};
      extraSpecialArgs = {
        inherit inputs;
      };
    };

  mkImage =
    {
      hostname,
      username ? "andrew",
      system ? "x86_64-linux",
      desktop ? null,
    }:
    nixos-generators.nixosGenerate {
      specialArgs = inputs // {
        inherit username hostname desktop;
      };
      system = system;
      format = "iso";

      modules = [ ../hosts ];
    };

  forAllSystems = inputs.nixpkgs.lib.genAttrs [
    "aarch64-linux"
    "x86_64-linux"
  ];
}
