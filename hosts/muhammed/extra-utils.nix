# This HM module adds extra utilities specific to this host.
{pkgs, ...}: let
  # Set some default options
  xkcdpass' = pkgs.writeShellScriptBin "xkcdpass" ''
    ${pkgs.xkcdpass}/bin/xkcdpass --delimiter="" --case capitalize --numwords=5 "$@"
  '';

  mcinfo = let
    jq-script = pkgs.writeText "minecraft.jq" ''
        .version as $v
      | .description as $d
      | .players as $p
      | (if env.NO_COLOR == null then "\u001b[1m" else "" end) as $bold
      | (if env.NO_COLOR == null then "\u001b[0m" else "" end) as $reset
      | "\($bold)Version:\($reset) \($v.name) (\($v.protocol))",
        "\($bold)Description:\($reset) \($d)",
        "\($bold)Players online\($reset): \($p.online)"
    '';
  in
    pkgs.writeShellScriptBin "mcinfo" ''
      set -x -u -o pipefail
      ${pkgs.mcping}/bin/mcping "$@" | jq --raw-output --from-file ${jq-script}
    '';
in {
  home.packages = with pkgs; [
    imagemagick
    ffmpeg_6-full

    # Generating passwords
    xkcdpass'

    # Quick monitoring of Minecraft servers
    mcping
    mcinfo
  ];
}
