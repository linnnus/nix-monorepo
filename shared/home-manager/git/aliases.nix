# This module defines my personal git aliases. Some of these are
# pseudo-subcommands which are easier to remember while others simply save me
# some keystrokes.
{...}: {
  programs.git.aliases = {
    unstage = "restore --staged"; # remove file from staging area
    undo = "reset --soft HEAD~"; # undo last commit
  };

  home.shellAliases = {
    gs = "git status";
    gd = "git diff --";
    gl = "git log --oneline HEAD~10..HEAD --";

    gc = "git commit";
    gcp = "git commit --patch";
    gf = "git commit --amend --no-edit --";
    gfp = "git commit --amend --no-edit --patch --";

    ga = "git add --";
    gan = "git add -N";
    gap = "git add --patch";
    gu = "git unstage";
  };
}
