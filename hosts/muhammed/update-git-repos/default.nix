{
  pkgs,
  lib,
  ...
}: {
  launchd.agents."update-git-repos" = {
    serviceConfig = {
      ProgramArguments = let
        awk-script = ''
          $1 == "origin" { origin = 1; }
          $1 == "upstream" { upstream = 1; }
          END { exit((origin & &upstream) ? 0 : 1) }
        '';

        script = pkgs.writeShellScript "update-git-repos" ''
          printf '\x1b[1m=> Syncing repos\x1b[0m\n'
          (cd ~/Source/nix ; gh repo sync linnnus/nix)
          printf '\x1b[1m=> Fetching repos\x1b[0m\n'
          find ~/Source ~/Projects -name '*.git' -print0 | while read -d $'\0' -r repo; do
            if git -C "$repo" remote | awk ${lib.escapeShellArg awk-script}; then
              printf '\x1b[1m=> Syncing %s\x1b[0m\n' "$repo"
              gh repo sync "linnnus/$(basename "$repo")"
            fi

            printf '\x1b[1m=> Updating %s\x1b[0m\n' "$repo"
            git -C "$repo" fetch --all
          done
        '';
      in
        # This *should* forward the scripts output to the universal logging system.
        # I can't really figure it out and I kind of hate all of Apple's tooling.
        ["/bin/sh" "-c" "${script} 2>&1 | logger -s"];

      # Only run this service when network is available.
      KeepAlive.NetworkState = true;

      StartInterval = 3600; # Once an hour.
    };
  };
}
