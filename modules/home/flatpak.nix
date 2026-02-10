_:

{
  services.flatpak = {
    enable = true;
    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];
    packages = [
      # Utilities
      "com.usebottles.bottles"
      "it.mijorus.gearlever"
      "com.github.tchx84.Flatseal"
      "org.filezillaproject.Filezilla"
      "org.qbittorrent.qBittorrent"
      "io.github.shundhammer.qdirstat"
      "org.bunkus.mkvtoolnix-gui"

      # Games
      "com.valvesoftware.SteamLink"
      "org.prismlauncher.PrismLauncher"

      # Productivity
      "org.libreoffice.LibreOffice"
      "io.github.brunofin.Cohesion"
      "io.github.pol_rivero.github-desktop-plus"

      # Communication
      "com.discordapp.Discord"
      "dev.vencord.Vesktop"
      "org.squidowl.halloy"
      "im.riot.Riot" # Element

      # Remote desktop clients
      "com.parsecgaming.parsec"
      "org.remmina.Remmina"
    ];
  };
}
