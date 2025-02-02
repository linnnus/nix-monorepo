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

    # I changed the default location after creating the world.
    data-dir = "/srv/minecrafter/papermc-1.21.4-15";

    # Gameplay settings.
    server-properties.level-seed = "1727502807"; # Seed requested by Tobias.
    server-properties.difficulty = "hard"; # Required for some game mechanic.
    server-properties.allow-cheats = true;
    server-properties.spawn-protection = 0; # Don't prevent building around spawn.

    # Whitelist generated with this command:
    # ```sh
    # journalctl --grep='UUID of' --unit=minecraft-server.service \
    #   | sed -E 's/.*UUID of player (.*) is (.*).*/"\1" = "\2";/p' -n \
    #   | sort -u
    # ```
    server-properties."white-list" = true;
    whitelist = {
      "BANANABARBARA" = "b3fa0532-e49c-4783-8ba4-e20082983d30";
      "em_T" = "c52db3ea-9f8a-4e0f-af11-7ca56099dfb1";
      "_SneakyPanda_" = "6f88ea4f-2f87-47c9-99dd-be16e68c9913";
      "TobiKanob1" = "07931771-f2eb-4894-ac84-d3a121086d9f";
      "Alfholm" = "6a0a1d3b-ad0f-4a73-8e0c-97782a380ff4";
      "XenoDK" = "df3a7f06-5baf-4f56-b78f-bac8e7f28dec";
      "xbx" = "59498ad4-f7c5-47cd-a63d-d3bd3712cb8a";
      "Tablefl1pp" = "f2534fcd-93a6-4823-8fa9-9849575983af";
    };

    ops = [
      {
        username = "BANANABARBARA";
        uuid = "b3fa0532-e49c-4783-8ba4-e20082983d30";
        level = 4;
        # I always need to get on in case something is going wrong.
        bypasses-player-limit = true;
      }
      {
        username = "Alfholm";
        uuid = "6a0a1d3b-ad0f-4a73-8e0c-97782a380ff4";
        level = 2;
      }
      {
        username = "_SneakyPanda_";
        uuid = "6f88ea4f-2f87-47c9-99dd-be16e68c9913";
        level = 2;
      }
    ];
  };

  # Update the DDNS.
  # This would be the "IP" we give to folks.
  services.cloudflare-dyndns.domains = ["minecraft.linus.onl"];
}
