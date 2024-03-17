{ config, lib, pkgs, ... }:
let
  keymap = key: action: desc: mode: {
    inherit key action mode;
    options.desc = desc;
  };

  luaKeymap = key: action: desc: mode: {
    inherit key action mode;
    options.desc = desc;
    lua = true;
  };
in {
  imports = [ ./lsp.nix ./telescope.nix ./terminal.nix ./telescope.nix ];

  options.homelab.nvim = with lib; {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    terraform = mkOption {
      type = types.bool;
      default = false;
    };
    csharp = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = lib.mkIf config.homelab.nvim.enable {
    programs.nixvim = {
      enable = true;

      globals = {
        mapleader = " ";
        maplocalleader = " ";
        have_nerd_font = true;
      };

      options = {
        relativenumber = true;
        mouse = "a";
        showmode = false;

        shiftwidth = 2;
        expandtab = true;
        tabstop = 2;
        softtabstop = 2;
        cmdheight = 0;
        signcolumn = "yes:1";
        cursorline = true;
        undofile = true;
        wrap = false;
        guifont = "FiraCode Nerd Font:h12";
        hlsearch = true;
        breakindent = true;

        ignorecase = true;
        smartcase = true;

        updatetime = 250;
        timeoutlen = 250;

        splitright = true;
        splitbelow = true;

        list = true;
        listchars = {
          tab = "» ";
          trail = "·";
          nbsp = "␣";
        };

        inccommand = "split";
        scrolloff = 10;
      };

      clipboard = {
        providers.xclip.enable = true;
        register = "unnamedplus";
      };

      keymaps = [
        (keymap "<Esc>" "<cmd>nohlsearch<CR>" "Clear search hightlight" "n")

        (luaKeymap "[d" "function() vim.diagnostic.goto_prev() end"
          "Go to previous [D]iagnostic message" "n")
        (luaKeymap "]d" "function() vim.diagnostic.goto_next() end"
          "Go to next [D]iagnostic message" "n")
        (luaKeymap "<leader>e" "function() vim.diagnostic.open_float() end"
          "Show diagnostic [E]rror messages" "n")
        (luaKeymap "<leader>q" "function() vim.diagnostic.setloclist() end"
          "Open diagnostic [Q]uickfix list" "n")

        (keymap "<Esc><Esc>" "<C-\\><C-n>" "Exit terminal mode" "t")

        (keymap "<C-h>" "<C-w><C-h>" "Move focus to the left window" "n")
        (keymap "<C-l>" "<C-w><C-l>" "Move focus to the right window" "n")
        (keymap "<C-j>" "<C-w><C-j>" "Move focus to the lower window" "n")
        (keymap "<C-k>" "<C-w><C-k>" "Move focus to the upper window" "n")

        (keymap "<C-Up>" "<C-w>+" "Resize window up" "n")
        (keymap "<C-Down>" "<C-w>-" "Resize window down" "n")
        (keymap "<C-Left>" "<C-w>>" "Resize window left" "n")
        (keymap "<C-Right>" "<C-w><" "Resize window right" "n")

        (keymap "<leader>f" "<Cmd>Neotree toggle reveal<CR>"
          "[F]ile tree toggle" "n")
        (keymap "<leader>c" "<Cmd>bdelete<CR>" "[C]lose buffer" "n")
        (keymap "H" "<Cmd>bprevious<CR>" "Previous buffer" "n")
        (keymap "L" "<Cmd>bnext<CR>" "Next buffer" "n")

        (keymap "<leader>hh" "<Cmd>Neogit<CR>" "Neogit" "n")
      ];

      autoGroups = { kickstart-highlight-yank = { clear = true; }; };

      autoCmd = [{
        event = [ "TextYankPost" ];
        desc = "Highlight when yanking (copying) text";
        group = "kickstart-highlight-yank";
        callback = { __raw = "function() vim.highlight.on_yank() end"; };
      }];

      plugins = {
        comment-nvim.enable = true;

        gitsigns = {
          enable = true;
          signs = {
            add.text = "+";
            change.text = "~";
            delete.text = "-";
          };
          onAttach.function = ''
            function(bufnr) 
              local gs = require('gitsigns')

              local function map(mode, l, r, desc)
                vim.keymap.set(mode, l, r, { desc = desc, buffer = bufnr })
              end

              -- Actions
              map('n', '<leader>hS', gs.stage_buffer, '[S]tage buffer')
              map('n', '<leader>hs', gs.stage_hunk, '[S]stage hunk')
              map('n', '<leader>hu', gs.undo_stage_hunk, '[U]ndo stage hunk')
              map('n', '<leader>hR', gs.reset_buffer, '[R]eset buffer')
              map('n', '<leader>hp', gs.preview_hunk, '[P]review hunk')
              map('n', '<leader>hb', function() gs.blame_line{full=true} end, '[B]lame line')
              map('n', '<leader>tb', gs.toggle_current_line_blame, '[T]oggle [B]lame')
              map('n', '<leader>hd', gs.diffthis, '[D]iff')
              map('n', '<leader>td', gs.toggle_deleted, '[T]oggle [D]eleted')
            end
          '';
        };

        neogit = { enable = true; };

        markdown-preview.enable = true;

        which-key = {
          enable = true;
          registrations = {
            "<leader>d" = "[D]ocument";
            "<leader>r" = "[R]ename";
            "<leader>s" = "[S]earch";
            "<leader>w" = "[W]orkspace";
            "<leader>t" = "[T]erminal";
            "<leader>h" = "Git";
          };
        };

        mini = {
          enable = true;
          modules = { statusline = { use_icons = true; }; };
        };

        auto-session = {
          enable = true;
          bypassSessionSaveFileTypes = [ "neo-tree" ];
        };

        neo-tree = {
          enable = true;
          filesystem = {
            followCurrentFile.enabled = true;
            filteredItems = {
              showHiddenCount = true;
              hideDotfiles = false;
              hideGitignored = true;
              hideByName = [ ".git" ];
              visible = true;
            };
          };
        };

        bufferline = {
          enable = true;
          diagnostics = "nvim_lsp";
          diagnosticsIndicator = ''
            function(count, level, diagnostics_dict, context)
              local icon = level:match("error") and " " or " "
              return " " .. icon .. count
            end
          '';
          offsets = [{
            filetype = "neo-tree";
            text = "File Explorer";
            text_align = "left";
          }];
        };

        noice = {
          enable = true;
          popupmenu.enabled = true;
          presets = {
            bottom_search = true;
            command_palette = true;
            long_message_to_split = true;
            inc_rename = false;
            lsp_doc_border = false;
          };
        };

        lualine = { enable = true; };
      };

      extraConfigVim = ''
        let g:auto_session_pre_save_cmds = ["Neotree close"]
      '';

      colorschemes.catppuccin = {
        enable = true;
        flavour = "mocha";
      };

      extraPlugins = with pkgs.vimPlugins; [ nvim-web-devicons ];

      extraConfigLua = ''
        require('nvim-web-devicons').setup()
      '';
    };
  };
}
