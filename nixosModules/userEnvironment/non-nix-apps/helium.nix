{ config, lib, pkgs, ... }:

let
  githubRepo = "imputnet/helium-linux";

  heliumDir = "/opt/helium";

  # Wrapper qui redirige vers le binaire telecharge par le script d'activation
  heliumWrapper = pkgs.writeShellScriptBin "helium" ''
    exec "${heliumDir}/helium" "$@"
  '';
in
{
  options.nixos = {
    userEnvironment.non-nix-apps.helium = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Helium.";
      };
    };
  };

  config = lib.mkIf (config.nixos.userEnvironment.non-nix-apps.helium.enable) {
    environment.systemPackages = [ heliumWrapper ];

    # Script d'activation : telecharge la derniere version de Helium a chaque rebuild
    # Les bibliotheques sont resolues par nix-ld (modules/nix-ld.nix)
    system.activationScripts.installHelium = ''
      HELIUM_DIR="${heliumDir}"
      VERSION_FILE="$HELIUM_DIR/.version"

      # Recupere la derniere version via l'API GitHub
      LATEST=$(${pkgs.curl}/bin/curl -sL \
        https://api.github.com/repos/${githubRepo}/releases/latest \
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
            "https://github.com/${githubRepo}/releases/download/$LATEST/helium-$LATEST-x86_64_linux.tar.xz" \
            -o "$TMPDIR/helium.tar.xz"

          rm -rf "$HELIUM_DIR"
          mkdir -p "$HELIUM_DIR"
          ${pkgs.gnutar}/bin/tar --use-compress-program=${pkgs.xz}/bin/xz \
            -xf "$TMPDIR/helium.tar.xz" \
            -C "$HELIUM_DIR" --strip-components=1
          echo "$LATEST" > "$VERSION_FILE"
          rm -rf "$TMPDIR"

          echo "Helium $LATEST installed successfully"
        else
          echo "Helium $CURRENT is up to date"
        fi
      fi
    '';
  };
}