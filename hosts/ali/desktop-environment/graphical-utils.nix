{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    mpv
  ];

  # Exclude some clutter.
  environment.xfce.excludePackages = with pkgs.xfce; [
    parole # Video player
  ];

  home-manager.users.linus = {
    imports = [
      ../../../shared/home-manager/firefox
    ];
  };
}
