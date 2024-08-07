{ config, lib, ... }:
{
  config = lib.mkIf config.homelab.nvim.enable {
    programs.nixvim = {
      plugins = {
        hmts.enable = true;
        treesitter = {
          enable = true;
          settings.indent.enable = true;
        };
      };
    };
  };
}
