{pkgs, ...}: {
  programs.neovim.plugins = [
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

        -- Use Guile to evaluate scheme buffers.
        local start_guile_repl = "StartGuileRepl";
        local sock_path = "/tmp/guile-repl.sock"
        vim.g["conjure#filetype#scheme"] = "conjure.client.guile.socket"
        vim.g["conjure#client#guile#socket#pipename"] = sock_path
        vim.api.nvim_create_user_command(start_guile_repl, function()
          local id = vim.fn.jobstart({
            "${pkgs.guile}/bin/guile",
            "--listen=" .. sock_path,
          })
          print("Started Guile job #" .. id)
        end, {
          desc = "Starts an Guile repl session listening on " .. sock_path,
        })

        -- Jump to bottom of log when new evaluation happens
        -- See: https://github.com/Olical/conjure/blob/58c46d1f4999679659a5918284b574c266a7ac83/doc/conjure.txt#L872
        vim.cmd [[autocmd User ConjureEval if expand("%:t") =~ "^conjure-log-" | exec "normal G" | endif]]
      '';
    }

    # Compe plugin to interact with conjure.
    pkgs.vimPlugins.cmp-conjure
  ];
}