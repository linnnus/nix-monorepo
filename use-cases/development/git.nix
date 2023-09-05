{ ... }:

{
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
    gap = "git add --patch";
  };
}
