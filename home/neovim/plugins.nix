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
        -- Create a command to launch NRepl for Clojure support.
        -- See: https://github.com/Olical/conjure/wiki/Quick-start:-Clojure
        vim.api.nvim_create_user_command("NRepl", function()
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
        end, {
          desc = "Starts an NRepl session in the current directory (for use w/ conjure).",
        })
      '';
    }
  ];
}
