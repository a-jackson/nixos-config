{ config, lib, ... }:
{
  config = lib.mkIf config.homelab.nvim.enable {
    programs.nixvim = {
      plugins = {
        hmts.enable = true;
        treesitter = {
          enable = true;
          settings = {
            highlight.enable = true;
            incremental_selection.enable = true;
            indent.enable = true;
          };
        };
      };
    };
  };
}
