{ config, lib, ... }: {
  config = lib.mkIf config.homelab.nvim.enable {
    programs.nixvim = {
      plugins.toggleterm.enable = true;

      keymaps = let
        map = key: action: desc: mode: {
          inherit key action mode;
          options.desc = desc;
        };
      in [
        (map "<leader>tf" "<Cmd>ToggleTerm direction=float<CR>"
          "[T]erminal [F]loat" "n")
        (map "<leader>th" "<Cmd>ToggleTerm direction=horizontal size=10<CR>"
          "[T]erminal [H]orizontal" "n")
        (map "<leader>tv" "<Cmd>ToggleTerm direction=vertical size=80<CR>"
          "[T]erminal [V]ertical" "n")
        (map "<F7>" "<Cmd>ToggleTerm<CR>" "Toggle Terminal" [ "n" "t" ])
        (map "<C-t>" "<Cmd>ToggleTerm<CR>" "Toggle Terminal" [ "n" "t" ])
      ];
    };
  };
}
