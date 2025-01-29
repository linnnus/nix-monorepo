# This module configures a Minecraft server.
#
# Most of the heavy lifting is done in the reusable module `modules/nixos/on-demand-minecraft/`.
{pkgs, ...}: {
  # Set up Minecraft server.
  services.on-demand-minecraft = {
    enable = true;
    eula = true;

    package = pkgs.unstable.papermc;

    openFirewall = true;

    # Try shutting down every 10 minutes.
    frequency-check-players = "*-*-* *:00/10:00";

    # Seed requested by Tobias.
    server-properties."level-seed" = "1727502807";

    # I changed the default location after creating the world.
    data-dir = "/srv/minecrafter/papermc-1.21.4-15";
  };

  # Update the DDNS.
  # This would be the "IP" we give to folks.
  services.cloudflare-dyndns.domains = ["minecraft.linus.onl"];
}
