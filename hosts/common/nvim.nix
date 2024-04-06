{ nixvim, ... }:
{

  imports = [ nixvim.nixosModules.nixvim ];
  homelab.nvim.enable = true;
}
