# This HM module sets pr
{pkgs, ...}: {
  programs.firefox = {
    policies = {
      DisableTelemetry = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };

      # Disable various features, that we don't want.
      DisablePocket = true;
      DisableFirefoxStudies = true;
      DisableFirefoxAccounts = true;
      DisableAccounts = true;
      DisableFirefoxScreenshots = true;
    };

    profiles."default".extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
      # Block ads & tracking
      ublock-origin
      # Automatically reject cookies
      istilldontcareaboutcookies
    ];
  };
}
