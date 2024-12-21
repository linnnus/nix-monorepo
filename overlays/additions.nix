# This file contains an overlay which adds all the custom packages from `pkgs/`.
final: prev: {
  duksebot = prev.callPackage ../pkgs/duksebot {};

  tcl-cmark = prev.callPackage ../pkgs/tcl-cmark {};

  still-awake = prev.callPackage ../pkgs/still-awake {};

  trash = prev.callPackage ../pkgs/trash {};

  mcping = prev.callPackage ../pkgs/mcping {};

  # This is not wrapping the YaLafi python library, just a particular example
  # from the repo where they spellcheck LaTex files.
  yalafi-shell = prev.callPackage ../pkgs/yalafi-shell {};

  pbv = prev.callPackage ../pkgs/pbv {};

  vemf-unwrapped = prev.callPackage ../pkgs/vemf-unwrapped {};

  vemf = prev.callPackage ../pkgs/vemf {};

  cscript = prev.callPackage ../pkgs/cscript {};

  human-sleep = prev.callPackage ../pkgs/human-sleep {};

  disable-sleep = prev.callPackage ../pkgs/disable-sleep {};

  nowrap = prev.callPackage ../pkgs/nowrap {};

  echoargs = prev.callPackage ../pkgs/echoargs {};

  vimPlugins = prev.vimPlugins.extend (final': prev': {
    vim-crystal = prev.callPackage ../pkgs/vim-crystal {};
    vim-noweb = prev.callPackage ../pkgs/vim-noweb {};
    vim-janet = prev.callPackage ../pkgs/vim-janet {};
  });
}
