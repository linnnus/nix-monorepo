{
  pkgs,
  config,
  ...
}: {
  # TEMP: Tell age that secrets should be decrypted through personal key.
  # FIXME: These should probably be rekeyed with a system-wide key.
  age.identityPaths = [
    "${config.users.users.linus.home}/.ssh/id_rsa"
  ];

  # The current setup is an SFTP server with the username 'linus' and a
  # password. This is far from ideal but beggars can't be choosers...
  age.secrets.wraaath-sftp-password.file = ../../../secrets/wraaath-sftp-password.txt.age;

  launchd.daemons.wraaath-sftp = {
    script = ''
      set -xue

      # Create the mount point.
      # Should be automatically deleted upon unmount.
      mkdir -p /Volumes/Wraaath

      # Start a MacFUSE daemon.
      # Will run in background mode, as foreground mode broke everything for some reason.
      exec ${pkgs.sshfs}/bin/sshfs linus@ddns.wraaath.com:/ /Volumes/Wraaath \
        -p 2222 \
        -o volname=Wraath \
        -o reconnect \
        -o allow_other \
        -o password_stdin <${config.age.secrets.wraaath-sftp-password.path}
    '';

    serviceConfig = {
      # XXX
      AbandonProcessGroup = true;

      # XXX
      KeepAlive.NetworkState = true;
    };
  };
}
