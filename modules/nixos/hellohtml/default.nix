{ config, lib, pkgs, ... }:

# FIXME: It is wasteful to always run the service. We should run on-demand instead.
#        This is usually achieved using SystemD sockets [4] but we are blocked on missing
#        features in Deno [1, 5].
#
#        We have to be able to listen on a socket that's already been created by binding
#        an open file descriptor (or listening on stdin) [3]. This is not possible in Deno
#        as it is now [1, 2, 6].
#
#        Once it becomes a possibility, we should mirror the way push-notification-api works
#        as of b9ed407 [8, 7].
#
#        [1]: https://github.com/denoland/deno/issues/6529
#        [2]: https://github.com/denoland/deno/blob/1dd1aba2448c6c8a5a0370c4066a68aca06b859b/ext/net/ops_unix.rs#L207C34-L207C34
#        [3]: https://www.freedesktop.org/software/systemd/man/latest/systemd.socket.html#Description:~:text=Note%20that%20the,the%20service%20file).
#        [4]: https://www.freedesktop.org/software/systemd/man/latest/systemd.socket.html#Description:~:text=Socket%20units%20may%20be%20used%20to%20implement%20on%2Ddemand%20starting%20of%20services%2C%20as%20well%20as%20parallelized%20starting%20of%20services.%20See%20the%20blog%20stories%20linked%20at%20the%20end%20for%20an%20introduction.
#        [5]: https://github.com/denoland/deno/issues/14214
#        [6]: https://github.com/tokio-rs/tokio/issues/5678
#        [7]: https://github.com/benoitc/gunicorn/blob/660fd8d850f9424d5adcd50065e6060832a200d4/gunicorn/arbiter.py#L142-L155
#        [8]: https://github.com/linnnus/push-notification-api/tree/b9ed4071a4500a26b3b348a7f5fbc549e9694562

let
  cfg = config.services.hellohtml;
in
{
  options.services.hellohtml = {
    enable = lib.mkEnableOption "hellohtml service";

    port = lib.mkOption {
      description = "The port where hellohtml should listen.";
      type = lib.types.port;
      default = 8538;
    };
  };

  config = lib.mkIf cfg.enable {
    # Create a user for running service.
    users.users.hellohtml = {
      group = "hellohtml";
      description = "Runs hellohtml service";
      isSystemUser = true;
      home = "/srv/hellohtml";
      createHome = true; # Store DB here.
    };
    users.groups.hellohtml = { };

    # Create hellohtml service.
    systemd.services.hellohtml = {
      description = "HelloHTML server!!!";

      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig =
        let
          src = pkgs.fetchFromGitHub {
            owner = "linnnus";
            repo = "hellohtml";
            rev = "8505b271f0db4e8b26c95fe04855ce88954d67f7";
            hash = "sha256-om8w8K6EVxQ0Hn6VkCPtrc1qV48BpHzPQckOLpAiosI=";
          };

          hellohtml-vendor = pkgs.stdenv.mkDerivation {
            name = "hellohtml-vendor";
            nativeBuildInputs = [ pkgs.unstable.deno ];
            inherit src;
            buildCommand = ''
              # Deno wants to create cache directories.
              HOME="$(mktemp -d)"
              # Thought this wasn't necessary???
              cd $src
              # Build directory containing offline deps + import map.
              deno vendor --output=$out ./src/server.ts
            '';
            outputHashAlgo = "sha256";
            outputHashMode = "recursive";
            outputHash = "sha256-TMijSneZhvkAQb6TXF5mgf+nAcYogEfNYYpnui6i7PI";
          };

          hellohtml-drv = pkgs.writeShellScript "hellohtml" ''
            export HELLOHTML_DB_PATH="${config.users.users.hellohtml.home}"/hello.db
            export HELLOHTML_PORT=${toString cfg.port}
            export HELLOHTML_BASE_DIR="${src}"

            ${pkgs.unstable.deno}/bin/deno run \
              --allow-read=$HELLOHTML_BASE_DIR,$HELLOHTML_DB_PATH,. \
              --allow-write=$HELLOHTML_DB_PATH \
              --allow-net=0.0.0.0:$HELLOHTML_PORT \
              --allow-env \
              --no-prompt \
              --unstable-kv \
              --import-map=${hellohtml-vendor}/import_map.json \
              --no-remote \
              ${src}/src/server.ts
          '';
        in
        {
          Type = "simple";
          User = config.users.users.hellohtml.name;
          Group = config.users.users.hellohtml.group;
          ExecStart = "${hellohtml-drv}";

          # Harden service
          # NoNewPrivileges = "yes";
          # PrivateTmp = "yes";
          # PrivateDevices = "yes";
          # DevicePolicy = "closed";
          # ProtectControlGroups = "yes";
          # ProtectKernelModules = "yes";
          # ProtectKernelTunables = "yes";
          # RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6 AF_NETLINK";
          # RestrictNamespaces = "yes";
          # RestrictRealtime = "yes";
          # RestrictSUIDSGID = "yes";
          # MemoryDenyWriteExecute = "yes";
          # LockPersonality = "yes";
        };
    };
  };
}
