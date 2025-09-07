{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    mpv
  ];

  # Exclude some clutter.
  environment.gnome.excludePackages = with pkgs; [
    # TODO: Remove video player

    xterm
  ];
}
