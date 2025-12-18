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
      "com.discordapp.Discord"
      "org.prismlauncher.PrismLauncher"

      # Productivity
      "org.libreoffice.LibreOffice"
      "io.github.brunofin.Cohesion"
    ];
  };
}
