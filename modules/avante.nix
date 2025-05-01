{ pkgs, ... }:

{
  programs.nixvim.plugins.avante = {
    enable = true;

    settings = {
      provider = "openai";
      mode = "agentic";
      auto_suggestions_provider = "openai";

      openai = {
        endpoint     = "https://api.openai.com/v1";
        model        = "gpt-4o";
        timeout      = 30000;   # ms
        temperature  = 0.2;
      };

      system_instruction = ''
        you are a terse, precise, context-aware code assistant.
        never repeat the prompt, never hedge, ask for clarification only when strictly necessary.
      '';

      context = {
        max_lines     = 1000;
        project_scope = true;
      };

      behaviour = {
        auto_suggestions                  = false;
        auto_set_keymaps                  = true;
        auto_set_highlight_group          = true;
        auto_apply_diff_after_generation  = false;
        support_paste_from_clipboard      = false;
        minimize_diff                     = true;
        enable_token_counting             = true;
      };

      # explicit keymaps (mirrors the readme defaults)
      mappings = {
        ask     = "<leader>aa";
        edit    = "<leader>ae";
        refresh = "<leader>ar";
        focus   = "<leader>af";
        stop    = "<leader>aS";

        toggle = {
          default    = "<leader>at";
          debug      = "<leader>ad";
          hint       = "<leader>ah";
          suggestion = "<leader>as";
          repomap    = "<leader>aR";
        };

        sidebar = {
          apply_all            = "A";
          apply_cursor         = "a";
          retry_user_request   = "r";
          edit_user_request    = "e";
          switch_windows       = "<Tab>";
          reverse_switch_windows = "<S-Tab>";
          remove_file          = "d";
          add_file             = "@";
          close                = "q";
        };

        files = {
          add_current     = "ac";
          add_all_buffers = "aB";
        };

        select_model   = "a?";
        select_history = "ah";
      };
    };
  };
}