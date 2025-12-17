_:

{
  services.flatpak = {
    enable = true;
    remotes = {
      "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    };
    packages = [
      # Utilities
      "com.usebottles.bottles"

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
