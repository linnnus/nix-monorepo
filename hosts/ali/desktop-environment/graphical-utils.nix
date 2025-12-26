{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    mpv
  ];

  # Exclude some clutter.
  environment.xfce.excludePackages = with pkgs.xfce; [
    parole # Video player
  ];
}
