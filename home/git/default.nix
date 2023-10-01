{...}: {
  programs.git = {
    enable = true;

    # Set privacy-respecting user information.
    userName = "Linnnus";
    userEmail = "linnnus@users.noreply.github.com";
  };

  home.shellAliases = {
    gs = "git status";
    gd = "git diff";
    gc = "git commit";
    ga = "git add";
    gan = "git add -N";
    gap = "git add --patch";
  };
}
