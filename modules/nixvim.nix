{ pkgs, ... }:

let
  secrets = import ../secrets.nix;
in
{
  programs.nixvim = {
    enable = true;

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

    plugins.treesitter = {
      enable = true;
      ensureInstalled = [
        "javascript" "html" "css"
        "rust" "gdscript"
        "nix" "json"
      ];
    };

    plugins.lsp = {
      enable = true;
      servers = {
        tsserver.enable = true;
        html.enable = true;
        cssls.enable = true;
        rust-analyzer.enable = true;
        gdscript.enable = true;
        nil_ls.enable = true;
        jsonls.enable = true;
      };
    };

    plugins.cmp = {
      enable = true;
      autoEnableSources = true;
      sources = [
        { name = "nvim_lsp"; }
        { name = "buffer"; }
        { name = "path"; }
        { name = "luasnip"; }
      ];
    };

    plugins.luasnip.enable = true;

    plugins.none-ls = {
      enable = true;
      sources = {
        code_actions = { eslint_d.enable = true; };
        diagnostics = { eslint_d.enable = true; };
        formatting = {
          prettier.enable = true;
          rustfmt.enable = true;
        };
      };
    };

    plugins.telescope = {
      enable = true;
      extensions.fzf-native.enable = true;
    };

    plugins.nvim-tree.enable = true;
    plugins.gitsigns.enable = true;
    plugins.lualine.enable = true;
    plugins.which-key.enable = true;

    plugins.lazy = {
      enable = true;
      plugins = [
        {
          name = "gp.nvim";
          url = "https://github.com/Robitx/gp.nvim";
          lazy = false;
          config = ''
            require("gp").setup({
              openai_api_key = "${secrets.openaiApiKey}",
              chat_model = "gpt-4",
              chat_topic_gen_model = "gpt-3.5-turbo",
              curl_params = { timeout = 30 },
            })

            vim.keymap.set("n", "<leader>cc", "<cmd>GpChatNew vsplit<cr>", { desc = "New Chat" })
            vim.keymap.set("v", "<leader>ce", ":<C-u>'<,'>GpChatNew vsplit<cr>", { desc = "Chat Edit Selection" })
            vim.keymap.set("v", "<leader>cr", ":<C-u>'<,'>GpRewrite<cr>", { desc = "Rewrite Selection" })
          '';
        }
      ];
    };

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
