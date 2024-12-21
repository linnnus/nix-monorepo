{pkgs, ...}: {
  home.packages = with pkgs; [
    noweb
    texliveFull
    yalafi-shell
  ];

  programs.neovim.plugins = with pkgs.vimPlugins; [
    vim-noweb
  ];

  # Prepend nowebs STY files to the search path. I chose to do it globally,
  # rather than using `makeWrapper` because I sometimes want to manually invoke
  # `pdflatex` and the like on the output of `noweave`.
  home.sessionVariables.TEXINPUTS = "${pkgs.noweb.tex}/tex/latex/noweb/:$TEXINPUTS";
}
