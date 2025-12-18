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

      # Games
      "com.valvesoftware.Steam"
      "com.valvesoftware.SteamLink"
      "org.prismlauncher.PrismLauncher"

      # Productivity
      "org.libreoffice.LibreOffice"
      "io.github.brunofin.Cohesion"
      "io.github.shiftey.Desktop"

      # Communication
      "com.discordapp.Discord"
      "dev.vencord.Vesktop"

      # Remote desktop clients
      "com.parsecgaming.parsec"
      "org.remmina.Remmina"
    ];
  };
}
