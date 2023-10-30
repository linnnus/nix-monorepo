# This module sets up and configures various miscellaneous plugins.
# TODO: I fear this file will become the utils.lua of my Neovim configuration. Remove it!
{pkgs, ...}: {
  programs.neovim.plugins = [
    {
      plugin = pkgs.vimPlugins.vim-localvimrc;
      type = "viml";
      config = ''
        let g:localvimrc_persistent = 1
        let g:localvimrc_name = [ "local.vim", "editors/local.vim" ]
      '';
    }
    {
      plugin = pkgs.vimPlugins.vim-sneak;
      type = "viml";
      config = ''
        let g:sneak#s_next = 1
        let g:sneak#use_ic_scs = 1
        map f <Plug>Sneak_f
        map F <Plug>Sneak_F
        map t <Plug>Sneak_t
        map T <Plug>Sneak_T
      '';
    }
    {
      # Add interactive repl-like environment.
      # See also the addition of cmp-conjure in `completion.nix`.
      # See also the addition of clojure in `dev-utils/default.nix`.
      plugin = pkgs.vimPlugins.conjure;
      type = "lua";
      config = ''
        local start_clj_repl = "StartCljRepl";
        local start_lein_repl = "StartLeinRepl";

        -- Create a command to launch nRepl for Clojure support.
        -- See: https://github.com/Olical/conjure/wiki/Quick-start:-Clojure
        vim.api.nvim_create_user_command(start_clj_repl, function()
          local id = vim.fn.jobstart({
            "${pkgs.clojure}/bin/clj",
            "-Sdeps",
            '{:deps {nrepl/nrepl {:mvn/version "1.0.0"} cider/cider-nrepl {:mvn/version "0.40.0"}}}',
            "--main",
            "nrepl.cmdline",
            "--middleware",
            '["cider.nrepl/cider-middleware"]',
            "--interactive",
          })
          print("Started nRepl job #" .. id)
        end, {
          desc = "Starts an nRepl session in the current directory using clj.",
        })

        vim.api.nvim_create_user_command(start_lein_repl, function()
          local id = vim.fn.jobstart({
            "${pkgs.leiningen}/bin/lein",
            "repl",
          })
          print("Started nRepl job #" .. id)
        end, {
          desc = "Starts an nRepl session in the current directory using Lein.",
        })

        -- Launch nRepl when any clojure file is started.
        -- vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
        --   pattern = "*.clj",
        --   command = start_clj_repl,
        -- });

        -- Jump to bottom of log when new evaluation happens
        -- See: https://github.com/Olical/conjure/blob/58c46d1f4999679659a5918284b574c266a7ac83/doc/conjure.txt#L872
        vim.cmd [[autocmd User ConjureEval if expand("%:t") =~ "^conjure-log-" | exec "normal G" | endif]]
      '';
    }
  ];
}
