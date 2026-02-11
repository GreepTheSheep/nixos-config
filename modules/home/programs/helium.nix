{ pkgs, lib, config, ... }:

let
  heliumDir = "${config.home.homeDirectory}/.local/share/helium";

  # Wrapper qui redirige vers le binaire telecharge par le script d'activation
  heliumWrapper = pkgs.writeShellScriptBin "helium" ''
    exec "${heliumDir}/helium" "$@"
  '';
in
{
  home.packages = [ heliumWrapper ];

  # Symlink traque par home-manager vers le .desktop inclus dans l'archive
  home.file.".local/share/applications/helium.desktop".source =
    config.lib.file.mkOutOfStoreSymlink "${heliumDir}/helium.desktop";

  # Script d'activation : telecharge la derniere version de Helium a chaque rebuild
  # Les bibliotheques sont resolues par nix-ld (modules/nix-ld.nix)
  home.activation.installHelium = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    HELIUM_DIR="${heliumDir}"
    VERSION_FILE="$HELIUM_DIR/.version"

    # Recupere la derniere version via l'API GitHub
    LATEST=$(${pkgs.curl}/bin/curl -sL \
      https://api.github.com/repos/imputnet/helium-linux/releases/latest \
      | ${pkgs.jq}/bin/jq -r '.tag_name')

    if [ -z "$LATEST" ] || [ "$LATEST" = "null" ]; then
      echo "Warning: Could not fetch latest Helium version, skipping update"
    else
      CURRENT=""
      if [ -f "$VERSION_FILE" ]; then
        CURRENT=$(cat "$VERSION_FILE")
      fi

      if [ "$CURRENT" != "$LATEST" ]; then
        echo "Updating Helium: ''${CURRENT:-none} -> $LATEST"

        # Telecharge et extrait l'archive
        TMPDIR=$(mktemp -d)
        ${pkgs.curl}/bin/curl -sL \
          "https://github.com/imputnet/helium-linux/releases/download/$LATEST/helium-$LATEST-x86_64_linux.tar.xz" \
          -o "$TMPDIR/helium.tar.xz"

        rm -rf "$HELIUM_DIR"
        mkdir -p "$HELIUM_DIR"
        ${pkgs.gnutar}/bin/tar xf "$TMPDIR/helium.tar.xz" \
          -C "$HELIUM_DIR" --strip-components=1
        echo "$LATEST" > "$VERSION_FILE"
        rm -rf "$TMPDIR"

        # Patche le .desktop pour utiliser les chemins absolus du wrapper et de l'icone
        ${pkgs.gnused}/bin/sed -i \
          -e "s|Exec=helium|Exec=${heliumWrapper}/bin/helium|g" \
          -e "s|Icon=helium|Icon=$HELIUM_DIR/product_logo_256.png|g" \
          "$HELIUM_DIR/helium.desktop"

        echo "Helium $LATEST installed successfully"
      else
        echo "Helium $CURRENT is up to date"
      fi
    fi
  '';
}
