# nixvim.nix
{pkgs, ...}: {
  programs.nixvim = {
    enable = true;

    globals.mapleader = " ";
    colorschemes.nord.enable = true;

    # core opts
    opts = {
      mouse = "a";
      clipboard = "unnamed,unnamedplus";
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
      laststatus = 3;
    };

    # keymaps
    keymaps = [
      {
        mode = "n";
        key = "<leader>ff";
        action = "<cmd>Telescope find_files<cr>";
        options.desc = "find files";
      }
      {
        mode = "n";
        key = "<leader>xx";
        action = "<cmd>Telescope diagnostics<cr>";
        options.desc = "diagnostics (telescope)";
      }
      {
        mode = "n";
        key = "<leader>fg";
        action = "<cmd>Telescope live_grep<cr>";
        options.desc = "grep project";
      }
      # focus tree, then hop back
      {
        mode = "n";
        key = "<leader>te";
        action = "<cmd>NvimTreeFocus<cr>";
        options.desc = "focus tree";
      }
      {
        mode = "n";
        key = "<leader>tb";
        action = "<cmd>wincmd p<cr>";
        options.desc = "back to prev win";
      }
      {
        mode = "n";
        key = "<leader>fb";
        action = "<cmd>Telescope buffers<cr>";
        options.desc = "switch buffer";
      }
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>NvimTreeToggle<cr>";
        options.desc = "file tree";
      }
      {
        mode = "n";
        key = "<leader>ld";
        action = "<cmd>lua vim.diagnostic.open_float()<cr>";
        options.desc = "line diagnostics";
      }
    ];

    plugins = {
      web-devicons.enable = true;

      treesitter = {
        enable = true;
        settings.ensure_installed = [
          "javascript"
          "html"
          "css"
          "rust"
          "gdscript"
          "nix"
          "json"
          "lua"
          "bash"
        ];
      };

      toggleterm = {
        enable = true;
        settings = {
          open_mapping = "[[<c-n>]]";
          direction = "float";
          float_opts = {border = "curved";};
          shade_terminals = true;
          start_in_insert = true;
          persist_size = true;
        };
      };

      # rust tooling
      rustaceanvim = {
        enable = true;
        settings = {
          tools = {
            inlay_hints = {
              auto = true;
              only_current_line = false;
              show_parameter_hints = true;
              parameter_hints_prefix = "<- ";
              other_hints_prefix = "=> ";
            };
          };
          server = {
            on_attach = ''
              function(client, bufnr)
                -- neovim 0.10+: vim.lsp.inlay_hint.enable(bufnr, true)
                local ok = pcall(function() vim.lsp.inlay_hint.enable(bufnr, true) end)
                if not ok then
                  -- neovim 0.9: vim.lsp.inlay_hint(bufnr, true)
                  pcall(function() vim.lsp.inlay_hint(bufnr, true) end)
                end
              end
            '';
            default_settings = {
              rust-analyzer = {
                installCargo = false;
                installRustc = false;
                cargo = {
                  allFeatures = true;
                  features = "all";
                };
                check = {
                  allFeatures = true;
                  command = "clippy";
                };
              };
            };
          };
        };
      };

      lsp = {
        enable = true;
        servers = {
          ts_ls.enable = true;
          html.enable = true;
          cssls.enable = true;
          jsonls.enable = true;
          nil_ls.enable = true;
          lua_ls.enable = true;
          bashls.enable = true;
          gdscript = {
            enable = true;
            package = null;
          };
        };
      };

      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          sources = [
            {name = "nvim_lsp";}
            {name = "buffer";}
            {name = "path";}
            {name = "luasnip";}
          ];
          mapping = {
            "<Tab>" = "cmp.mapping.select_next_item()";
            "<S-Tab>" = "cmp.mapping.select_prev_item()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<C-Space>" = "cmp.mapping.complete()";
          };
        };
      };

      luasnip.enable = true;

      telescope = {
        enable = true;
        extensions.fzf-native.enable = true;
      };

      gitsigns.enable = true;
      lualine.enable = true;
      which-key.enable = true;

      # formatting via none-ls
      none-ls = {
        enable = true;
        sources.formatting = {
          prettier = {
            enable = true;
            disableTsServerFormatter = true;
          };
          stylua.enable = true; # lua
          alejandra.enable = true; # nix
        };
      };

      # auto-format on save
      lsp-format.enable = true;

      # nvim-tree with new settings.* schema
      nvim-tree = {
        enable = true;
        settings = {
          auto_reload_on_write = true;
          disable_netrw = true;
          hijack_netrw = true;

          update_focused_file = {
            enable = true;
            update_root = true;
          };

          renderer = {
            group_empty = true;
          };

          git = {
            enable = true;
            ignore = false;
          };

          view = {
            width = 32;
            side = "left";
            preserve_window_proportions = true;
          };
        };
      };
    };

    # small ui tweak for inlay hints highlight
    extraConfigLua = ''
      vim.api.nvim_set_hl(0, "LspInlayHint", {
        fg = "#81A1C1",
        bg = "#2E3440",
        italic = true,
      })
    '';
  };
}
