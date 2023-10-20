# This module defines my personal git aliases. Some of these are
# pseudo-subcommands which are easier to remember while others simply save me
# some keystrokes.
{...}: {
  programs.git.aliases = {
    unstage = "restore --staged";
    forgor = "commit --amend --no-edit --";
  };

  home.shellAliases = {
    gs = "git status";
    gd = "git diff --";

    gc = "git commit";
    gf = "git forgor";

    ga = "git add --";
    gan = "git add -N";
    gap = "git add --patch";
    gu = "git unstage";
  };
}
