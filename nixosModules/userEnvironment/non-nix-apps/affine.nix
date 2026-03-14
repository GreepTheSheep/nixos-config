{ config, lib, pkgs, ... }:

let
  githubRepo = "toeverything/AFFiNE";

  affineDir = "/opt/affine";

  # Wrapper qui redirige vers le binaire telecharge par le script d'activation
  affineWrapper = pkgs.writeShellScriptBin "affine" ''
    exec "${affineDir}/affine" "$@"
  '';
in
{
  options.nixos = {
    userEnvironment.non-nix-apps.affine = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable AFFiNE.";
      };
    };
  };

  config = lib.mkIf (config.nixos.userEnvironment.non-nix-apps.affine.enable) {
    environment.systemPackages = [ affineWrapper ];

    # Script d'activation : telecharge la derniere version de Helium a chaque rebuild
    # Les bibliotheques sont resolues par nix-ld (modules/nix-ld.nix)
    system.activationScripts.installAffine = ''
      AFFINE_DIR="${affineDir}"
      VERSION_FILE="$AFFINE_DIR/.version"

      # Recupere la derniere version via l'API GitHub
      LATEST=$(${pkgs.curl}/bin/curl -sL \
        https://api.github.com/repos/${githubRepo}/releases/latest \
        | ${pkgs.jq}/bin/jq -r '.tag_name')

      if [ -z "$LATEST" ] || [ "$LATEST" = "null" ]; then
        echo "Warning: Could not fetch latest AFFiNE version, skipping update"
      else
        CURRENT=""
        if [ -f "$VERSION_FILE" ]; then
          CURRENT=$(cat "$VERSION_FILE")
        fi

        if [ "$CURRENT" != "$LATEST" ]; then
          echo "Updating AFFiNE: ''${CURRENT:-none} -> $LATEST"

          # Telecharge et extrait l'archive
          mkdir -p /tmp
          TMPDIR=$(mktemp -d -p /tmp)
          ${pkgs.curl}/bin/curl -sL \
            "https://github.com/${githubRepo}/releases/download/$LATEST/affine-''${LATEST#v}-stable-linux-x64.zip" \
            -o "$TMPDIR/affine.zip"

          rm -rf "$AFFINE_DIR"
          mkdir -p "$AFFINE_DIR"
          ${pkgs.unzip}/bin/unzip -q "$TMPDIR/affine.zip" -d "$TMPDIR"
          mv "$TMPDIR/AFFiNE-linux-x64/"* "$AFFINE_DIR/"
          echo "$LATEST" > "$VERSION_FILE"
          rm -rf "$TMPDIR"

          echo "AFFiNE $LATEST installed successfully"
        else
          echo "AFFiNE $CURRENT is up to date"
        fi
      fi
    '';
  };
}