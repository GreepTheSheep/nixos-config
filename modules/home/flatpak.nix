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
      "io.github.pol_rivero.github-desktop-plus"
      "md.obsidian.Obsidian"

      # Communication
      "com.discordapp.Discord"
      "dev.vencord.Vesktop"
      "org.squidowl.halloy"
      "im.riot.Riot" # Element

      # Remote desktop clients
      "com.parsecgaming.parsec"
      "org.remmina.Remmina"

      # OBS Studio and its plugins
      "com.obsproject.Studio"
      "com.obsproject.Studio.Plugin.OBSVkCapture"
      "com.obsproject.Studio.Plugin.WaylandHotkeys"
      "com.obsproject.Studio.Plugin.SceneSwitcher"
      "com.obsproject.Studio.Plugin.InputOverlay"
      "com.obsproject.Studio.Plugin.AudioMonitor"
      "com.obsproject.Studio.Plugin.MoveTransition"
      "com.obsproject.Studio.Plugin.Countdown"
      "com.obsproject.Studio.Plugin.waveform"
      "com.obsproject.Studio.Plugin.SourceClone"
      "com.obsproject.Studio.Plugin.AsyncAudioFilter"
      "com.obsproject.Studio.Plugin.OBSPWVideo"
    ];
  };
}
