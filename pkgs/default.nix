pkgs: {
  duksebot = pkgs.callPackage ./duksebot {};

  tcl-cmark = pkgs.callPackage ./tcl-cmark {};

  still-awake = pkgs.callPackage ./still-awake {};

  trash = pkgs.callPackage ./trash {};

  mcping = pkgs.callPackage ./mcping {};

  watch-while = pkgs.callPackage ./watch-while {};

  # This is not wrapping the YaLafi python library, just a particular example
  # from the repo where they spellcheck LaTex files.
  yalafi-shell = pkgs.callPackage ./yalafi-shell {};

  pbv = pkgs.callPackage ./pbv {};

  vemf-unwrapped = pkgs.callPackage ./vemf-unwrapped {};

  vemf = pkgs.callPackage ./vemf {};

  cscript = pkgs.callPackage ./cscript {};

  human-sleep = pkgs.callPackage ./human-sleep {};

  # TODO: These should be contained in the 'vimPlugins' attrset. This turns out
  # to be non-trivial because this module is both consumed in a flake output
  # context and an overlay context.
  #
  # See: https://nixos.wiki/wiki/Overlays#Overriding_a_package_inside_an_extensible_attribute_set
  vim-crystal = pkgs.callPackage ./vim-crystal {};
  vim-noweb = pkgs.callPackage ./vim-noweb {};
  vim-janet = pkgs.callPackage ./vim-janet {};
}
