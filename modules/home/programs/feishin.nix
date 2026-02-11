{ pkgs, lib, config, ... }:

let
  feishinDir = "${config.home.homeDirectory}/.local/share/feishin";

  # Wrapper qui redirige vers le binaire telecharge par le script d'activation
  feishinWrapper = pkgs.writeShellScriptBin "feishin" ''
    exec "${feishinDir}/feishin" "$@"
  '';
in
{
  home.packages = [ feishinWrapper ];

  # Script d'activation : telecharge la derniere version de Feishin a chaque rebuild
  # Les bibliotheques sont resolues par nix-ld (modules/nix-ld.nix)
  home.activation.installFeishin = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    FEISHIN_DIR="${feishinDir}"
    VERSION_FILE="$FEISHIN_DIR/.version"

    # Recupere la derniere version via l'API GitHub
    LATEST=$(${pkgs.curl}/bin/curl -sL \
      https://api.github.com/repos/jeffvli/feishin/releases/latest \
      | ${pkgs.jq}/bin/jq -r '.tag_name')

    if [ -z "$LATEST" ] || [ "$LATEST" = "null" ]; then
      echo "Warning: Could not fetch latest Feishin version, skipping update"
    else
      CURRENT=""
      if [ -f "$VERSION_FILE" ]; then
        CURRENT=$(cat "$VERSION_FILE")
      fi

      if [ "$CURRENT" != "$LATEST" ]; then
        echo "Updating Feishin: ''${CURRENT:-none} -> $LATEST"

        # Telecharge et extrait l'archive
        TMPDIR=$(mktemp -d)
        ${pkgs.curl}/bin/curl -sL \
          "https://github.com/jeffvli/feishin/releases/download/$LATEST/Feishin-linux-x64.tar.xz " \
          -o "$TMPDIR/feishin.tar.xz"

        rm -rf "$FEISHIN_DIR"
        mkdir -p "$FEISHIN_DIR"
        ${pkgs.gnutar}/bin/tar --use-compress-program=${pkgs.xz}/bin/xz \
          -xf "$TMPDIR/feishin.tar.xz" \
          -C "$FEISHIN_DIR" --strip-components=1
        echo "$LATEST" > "$VERSION_FILE"
        rm -rf "$TMPDIR"

        echo "Feishin $LATEST installed successfully"
      else
        echo "Feishin $CURRENT is up to date"
      fi
    fi
  '';

  # XDG desktop entry pour le launcher d'applications
  xdg.desktopEntries.feishin = {
    name = "Feishin";
    comment = "A modern self-hosted music player.";
    genericName = "A modern self-hosted music player.";
    exec = "${feishinWrapper}/bin/feishin --no-sandbox %U";
    icon = "${feishinDir}/resources/assets/icons/icon.png";
    startupNotify = true;
    categories = [ "Audio" "Music" "Player" ];
    settings = {
      StartupWMClass = "Feishin";
      Keywords = "feishin music player";
    };
  };
}
