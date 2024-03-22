{ self, inputs }:
let inherit (inputs) nixpkgs home-manager nixvim;
in {
  systemConfig = hostname: system:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = inputs // { inherit (self) libx; };
      modules = [ ../hosts/${hostname} { networking.hostName = hostname; } ];
    };
  homeConfig = username: hostname: system:
    home-manager.lib.homeManagerConfiguration {
      modules = [
        { imports = [ nixvim.homeManagerModules.nixvim ]; }
        ../home/${hostname}.nix
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
}
