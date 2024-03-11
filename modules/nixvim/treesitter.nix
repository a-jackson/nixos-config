{ config, lib, ... }: {
  config = lib.mkIf config.homelab.nvim.enable {
    programs.nixvim = {
      plugins.hmts.enable = true;
      plugins.treesitter = {
        enable = true;
        incrementalSelection.enable = true;
        incrementalSelection.keymaps.initSelection = "<A-h>";
        incrementalSelection.keymaps.nodeDecremental = "<A-l>";
        incrementalSelection.keymaps.nodeIncremental = "<A-h>";
      };
    };
  };
}
