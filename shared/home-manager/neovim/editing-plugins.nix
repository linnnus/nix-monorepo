# This module sets up and configures various miscellaneous plugins.
# TODO: I fear this file will become the utils.lua of my Neovim configuration. Remove it!
{
  pkgs,
  flakeInputs,
  lib,
  ...
}: {
  programs.neovim.plugins =
    [
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
        plugin = pkgs.vimPlugins.vim-easy-align;
        type = "viml";
        config = ''
          " Align the backslashes in multiline C-macros
          let g:easy_align_delimiters = { '\': { 'pattern': '\\$' } }
        '';
      }
      {
        plugin = pkgs.vimPlugins.vim-surround;
      }
    ]
    ++ lib.optionals (pkgs.stdenv.isDarwin) [
      {
        plugin = pkgs.vimPlugins.dark-notify;
        type = "viml";
        config = ''
          " Start interactive EasyAlign in visual mode (e.g. vipga)
          xmap ga <Plug>(EasyAlign)

          " Start interactive EasyAlign for a motion/text object (e.g. gaip)
          nmap ga <Plug>(EasyAlign)
        '';
      }
    ];
}
