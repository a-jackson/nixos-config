{ config, lib, ... }:
{
  config = lib.mkIf config.homelab.nvim.enable {
    programs.nixvim = {
      plugins.telescope = {
        enable = true;

        extensions = {
          fzf-native.enable = true;
          ui-select.enable = true;
          ui-select.settings = {
            __raw = "require('telescope.themes').get_dropdown()";
          };
        };

        keymaps = {
          "<leader>sh" = {
            options.desc = "[S]earch [H]elp";
            action = "help_tags";
          };
          "<leader>sk" = {
            options.desc = "[S]earch [K]eymaps";
            action = "keymaps";
          };
          "<leader>ss" = {
            options.desc = "[S]earch [S]elect Telescope";
            action = "builtin";
          };
          "<leader>sw" = {
            options.desc = "[S]earch current [W]ord";
            action = "grep_string";
          };
          "<leader>sg" = {
            options.desc = "[S]earch by [Grep]";
            action = "live_grep";
          };
          "<leader>sd" = {
            options.desc = "[S]earch [Diagnostics]";
            action = "diagnostics";
          };
          "<leader>sr" = {
            options.desc = "[S]earch [R]esume";
            action = "resume";
          };
          "<leader>s." = {
            options.desc = ''[S]earch Recent Files ("." for repeat)'';
            action = "oldfiles";
          };
          "<leader><leader>" = {
            options.desc = "[ ] Find existing buffers";
            action = "buffers";
          };
        };
      };

      keymaps = [
        {
          key = "<leader>/";
          action.__raw = ''
            function()
              require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                winblend = 10,
                previewer = false,
              })
            end
          '';
          mode = "n";
          options.desc = "[/] Fuzzily search in current buffer";
        }
        {
          key = "<leader>s/";
          action.__raw = ''
            function()
              require('telescope.builtin').live_grep {
                grep_open_files = true,
                prompt_title = 'Live Grep in Open Files',
              }
            end
          '';
          mode = "n";
          options.desc = "[S]earch [/] in Open Files";
        }
        {
          key = "<leader>sn";
          action.__raw = ''
            function()
              require('telescope.builtin').find_files {
                cwd = vim.fn.stdpath 'config'
              }
            end
          '';
          mode = "n";
          options.desc = "[S]earch [N]eovim files";
        }
        {
          key = "<leader>sf";
          action.__raw = ''
            function()
              require('telescope.builtin').git_files {
                hidden = true,
                no_ignore = true,
              }
            end
          '';
          mode = "n";
          options.desc = "[S]earch [F]iles";
        }
      ];
    };
  };
}
