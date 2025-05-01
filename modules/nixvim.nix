# nixvim.nix
{pkgs, ...}: {
  programs.nixvim = {
    enable = true;

    globals.mapleader = " ";
    colorschemes.nord.enable = true;

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

    keymaps = [
      {
        mode = "n";
        key = "<leader>ff";
        action = "<cmd>Telescope find_files<cr>";
        options.desc = "find files";
      }
      {
        mode = "n";
        key = "<leader>fg";
        action = "<cmd>Telescope live_grep<cr>";
        options.desc = "grep project";
      }
      # focus tree, then hop back to previous window
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

          rust_analyzer = {
            enable = true;
            installCargo = false;
            installRustc = false;
          };

          gdscript = {
            enable = true;
            package = null;
          };
        };
      };

      cmp = {
        enable = true;
        autoEnableSources = true;
        settings.sources = [
          {name = "nvim_lsp";}
          {name = "buffer";}
          {name = "path";}
          {name = "luasnip";}
        ];
      };

      luasnip.enable = true;

      telescope = {
        enable = true;
        extensions.fzf-native.enable = true;
      };

      gitsigns.enable = true;
      lualine.enable = true;
      which-key.enable = true;

      # none-ls for formatting only (built-ins known to nixvim)
      none-ls = {
        enable = true;
        sources.formatting = {
          prettier.disableTsServerFormatter = true;
          prettier.enable = true; # js / ts / html / css / json
          stylua.enable = true; # lua
          alejandra.enable = true; # nix
        };
      };

      # auto-format on save
      lsp-format.enable = true;

      # file tree (without deprecated setup flags)
      nvim-tree = {
        enable = true;

        # keep sidebar in sync with the buffer you’re editing
        #updateFocusedFile = {
        #  enable    = true;
        #  updateCwd = true;
        #};

        # collapse dir/with/single/child into one node
        renderer = {
          groupEmpty = true;
        };

        # git icons and lsp diagnostic badges
        git = {
          enable = true;
          ignore = false;
        };
        #diagnostics = {
        # enable     = true;
        #showOnDirs = true;
        #};

        # 32-column panel on the left, no auto-stretching
        view = {
          width = 32;
          side = "left";
          preserveWindowProportions = true;
        };
      };
    };
  };
}
