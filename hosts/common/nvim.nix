{ nixvim, pkgs, ... }:
let
  nixvim' = nixvim.legacyPackages.${pkgs.system};
  nvim = nixvim'.makeNixvimWithModule {
    inherit pkgs;
    module = import ./nixvim;
  };
in
{ environment.systemPackages = [ nvim pkgs.ripgrep ]; }
