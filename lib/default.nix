{ inputs }:
let
  inherit (inputs)
    nixpkgs
    home-manager
    nixvim
    ;
in
{
  mkSystem =
    {
      hostname,
      system ? "x86_64-linux",
      username ? "andrew",
      desktop ? null,
      homeType ? null,
    }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = inputs // {
        inherit
          username
          hostname
          desktop
          homeType
          ;
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
        {
          imports =
            [ nixvim.homeManagerModules.nixvim ];
        }
        ../home/${type}.nix
        {
          home = {
            username = nixpkgs.lib.mkDefault "${username}";
            homeDirectory = nixpkgs.lib.mkDefault "/home/${username}";
            stateVersion = "23.05";
          };
        }
        {
          nixpkgs.overlays = [
            (prev: final: {
              csharpier = prev.buildDotnetGlobalTool {
                pname = "csharpier";
                version = "0.28.0";
                executables = "dotnet-csharpier";
                nugetSha256 = "sha256-qR09YQF45QlwGuQ1iuebPMM3mJLx4S7uUJErZJDFhGI=";
              };
            })
          ];
        }
      ];
      pkgs = nixpkgs.legacyPackages.${system};
      extraSpecialArgs = {
        inherit inputs;
      };
    };

  forAllSystems = inputs.nixpkgs.lib.genAttrs [
    "aarch64-linux"
    "x86_64-linux"
  ];
}
