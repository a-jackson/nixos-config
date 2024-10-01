{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.homelab.nvim.enable {
    programs.nixvim = {
      plugins = {
        fidget.enable = true;
        lsp = {
          enable = true;
          servers =
            {
              eslint.enable = true;
              ts-ls.enable = true;
              cssls.enable = true;
              bashls.enable = true;
              html.enable = true;
              emmet-ls.enable = true;
              pyright.enable = true;
              nil-ls.enable = true;
              nixd.enable = true;
              marksman.enable = true;
              yamlls = {
                enable = true;
                extraOptions.settings = {
                  yaml = {
                    schemas = {
                      "https://json.schemastore.org/github-workflow.json" = "/.github/workflows/*";
                    };
                  };
                };
              };
            }
            // lib.optionalAttrs config.homelab.nvim.terraform { terraformls.enable = true; }
            // lib.optionalAttrs config.homelab.nvim.csharp { omnisharp.enable = true; };

          keymaps = {
            lspBuf =
              let
                map = action: desc: { inherit action desc; };
              in
              {
                "<leader>rn" = map "rename" "[R]e[n]ame";
                "<leader>ca" = map "code_action" "[C]ode [A]ction";
                "K" = map "hover" "Hover Documentation";
                "gD" = map "declaration" "[G]oto [D]eclaration";
              };
          };

          onAttach = ''
            if client and client.server_capabilities.documentHighlightProvider then
              vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                buffer = bufnr,
                callback = vim.lsp.buf.document_highlight,
              })

              vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                buffer = bufnr,
                callback = vim.lsp.buf.clear_references,
              })
            end
          '';

          preConfig = ''vim.lsp.set_log_level("OFF")'';
        };

        lspkind = {
          enable = true;
          mode = "symbol";
        };

        cmp-nvim-lsp.enable = true;

        cmp = {
          enable = true;
          settings = {
            sources = [
              {
                name = "nvim_lsp";
                priority = 1000;
              }
              {
                name = "luasnip";
                priority = 750;
              }
              {
                name = "buffer";
                priority = 500;
                option.get_bufnrs.__raw = "vim.api.nvim_list_bufs";
              }
              {
                name = "path";
                priority = 250;
              }
            ];
            snippet.expand = ''
              function(args)
                require('luasnip').lsp_expand(args.body)
              end
            '';
            mapping = {
              "<C-y>" = "cmp.mapping.confirm({ select = false })";
              "<C-Space>" = "cmp.mapping.complete()";
              "<C-p>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
              "<C-n>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
              "<C-l>" = ''
                cmp.mapping(function()
                  luasnip = require('luasnip')
                  if luasnip.expand_or_locally_jumpable() then
                    luasnip.expand_or_jump()
                  end
                end, { 'i', 's' })
              '';
              "<C-h>" = ''
                cmp.mapping(function()
                  luasnip = require('luasnip')
                  if luasnip.locally_jumpable(-1) then
                    luasnip.jump(-1)
                  end
                end, { 'i', 's' })
              '';
            };
          };
        };

        conform-nvim = {
          enable = true;
          settings.format_on_save = ''
            function(bufnr)
              if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                return
              end
              return { timeout_ms = 1000, lsp_fallback = true }
            end
          '';
        };

        cmp-path.enable = true;

        none-ls = {
          enable = true;
          sources.formatting = {
            prettier.enable = true;
            prettier.disableTsServerFormatter = true;
            black.enable = true;
            nixfmt.enable = true;
            nixfmt.package = pkgs.nixfmt-rfc-style;
          } // lib.optionalAttrs config.homelab.nvim.csharp { csharpier.enable = true; };
        };

        luasnip.enable = true;
        luasnip.fromVscode = [ { } ];
        friendly-snippets.enable = true;

        cmp_luasnip.enable = true;
      };

      keymaps =
        let
          lspKeymap = key: action: desc: {
            inherit key;
            options.desc = desc;
            mode = "n";
            action.__raw = ''
              function()
                require('telescope.builtin').${action}()
              end
            '';
          };
        in
        [
          (lspKeymap "gd" "lsp_definitions" "[G]oto [D]efinition")
          (lspKeymap "gr" "lsp_references" "[G]oto [R]eferences")
          (lspKeymap "gI" "lsp_implementations" "[G]oto [I]mplementation")
          (lspKeymap "<leader>D" "lsp_type_definitions" "Type [D]efinition")
          (lspKeymap "<leader>ds" "lsp_document_symbols" "[D]ocument [S]ymbols")
          (lspKeymap "<leader>ws" "lsp_dynamic_workspace_symbols" "[W]orkspace [S]ymbols")
          {
            key = "<leader>df";
            options.desc = "[D]ocument toggle auto [F]ormat";
            mode = "n";
            action.__raw = ''
              function()
                if vim.b.disable_autoformat then
                  vim.b.disable_autoformat = false
                  require("notify")("Autoformat enabled on current buffer")
                else
                  vim.b.disable_autoformat = true
                  require("notify")("Autoformat disabled on current buffer")
                end
              end
            '';
          }
          {
            key = "<leader>wf";
            options.desc = "[W]orkspace toggle auto [F]ormat";
            mode = "n";
            action.__raw = ''
              function()
                if vim.g.disable_autoformat then
                  vim.g.disable_autoformat = false
                  require("notify")("Autoformat enabled in workspace")
                else
                  vim.g.disable_autoformat=true
                  require("notify")("Autoformat disabled in workspace")
                end
              end
            '';
          }
        ];
    };
  };
}
