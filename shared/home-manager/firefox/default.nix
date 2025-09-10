# This module configures Firefox with all my plugins and such.
{pkgs, ...}: {
  imports = [
    ./privacy.nix
  ];

  programs.firefox = {
    enable = true;

    profiles."default" = {
      settings."extensions.autoDisableScopes" = 0;
      settings."extensions.enabledScopes" = 15;

      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        # Avoid accidental doom-scrolling
        news-feed-eradicator
        # Automatically redirect to old.reddit instead of the redesign.
        old-reddit-redirect
      ];
    };
  };
}
