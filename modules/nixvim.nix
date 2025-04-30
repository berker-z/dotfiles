{ pkgs, ... }:

{
  programs.nixvim = {
    enable = true;

    globals.mapleader = " ";
    colorschemes.nord.enable = true;

    opts = {
      mouse = "a";
      clipboard = "unnamedplus";
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
    };

    plugins.web-devicons.enable = true;

    plugins.treesitter = {
      enable = true;
      settings.ensure_installed = [
        "javascript" "html" "css"
        "rust" "gdscript"
        "nix" "json"
      ];
    };

    plugins.lsp = {
      enable = true;
      servers = {
        ts_ls.enable = true;
        html.enable = true;
        cssls.enable = true;
        jsonls.enable = true;
        nil_ls.enable = true;

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

    plugins.cmp = {
      enable = true;
      autoEnableSources = true;
      settings.sources = [
        { name = "nvim_lsp"; }
        { name = "buffer"; }
        { name = "path"; }
        { name = "luasnip"; }
      ];
    };

    plugins.luasnip.enable = true;

    plugins.telescope = {
      enable = true;
      extensions.fzf-native.enable = true;
    };

    plugins.nvim-tree.enable = true;
    plugins.gitsigns.enable = true;
    plugins.lualine.enable = true;
    plugins.which-key.enable = true;

    keymaps = [
      {
        mode = "n";
        key = "<leader>ff";
        action = "<cmd>Telescope find_files<cr>";
        options.desc = "Find files";
      }
    ];
  };
}
