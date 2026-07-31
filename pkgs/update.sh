#!/usr/bin/env bash
# Met a jour les paquets locaux du dossier pkgs/.
# Usage: ./pkgs/update.sh [nom-paquet] [version]
#
# Exemples:
#   ./pkgs/update.sh                     # met a jour TOUS les paquets de pkgs/
#   ./pkgs/update.sh nxapi               # met a jour nxapi uniquement (derniere version)
#   ./pkgs/update.sh nxapi 1.7.0         # nxapi vers une version specifique
#
# Prerequis: nix-update (dispo via `nix run nixpkgs#nix-update`)
#            jq, nix-prefetch-url, python3

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PKGS_DIR="$REPO_ROOT/pkgs"

# --- Liste les paquets disponibles (un par sous-dossier avec un default.nix) ---
list_packages() {
  for d in "$PKGS_DIR"/*/; do
    [ -f "$d/default.nix" ] && basename "$d"
  done
}

# --- Met a jour un paquet donne ---
update_package() {
  local pkg_name="$1"
  local version_arg=""

  if [ $# -eq 2 ]; then
    version_arg="--version $2"
    echo "Version cible: $2"
  else
    echo "Version cible: derniere disponible"
  fi

  local pkg_dir="$PKGS_DIR/$pkg_name"
  if [ ! -d "$pkg_dir" ]; then
    echo "Erreur: le dossier $pkg_dir n'existe pas"
    return 1
  fi

  echo "=== Mise a jour: $pkg_name ==="

  # Detecte les particularites du paquet
  local needs_insecure=false
  for f in "$pkg_dir"/*.nix; do
    if grep -qE "electron_[0-9]+|nodejs_[0-9]+" "$f"; then
      needs_insecure=true
      break
    fi
  done

  local nix_update_args="--flake $version_arg"
  local build_cmd="nix build .#$pkg_name --no-link --print-out-paths"

  if [ "$needs_insecure" = true ]; then
    echo "  (dependances insecure -> NIXPKGS_ALLOW_INSECURE=1 --impure)"
    nix_update_args="$nix_update_args --impure"
    build_cmd="NIXPKGS_ALLOW_INSECURE=1 $build_cmd --impure"
    export NIXPKGS_ALLOW_INSECURE=1
  fi

  # nix-update met a jour version + hashes automatiquement
  echo "--- nix-update ---"
  nix run nixpkgs#nix-update -- $nix_update_args "$pkg_name" || {
    echo "nix-update a echoue pour $pkg_name"
    return 1
  }

  # Verifie le build
  echo "--- Verification du build ---"
  eval "$build_cmd" 2>&1 | tail -5 || {
    echo "Build echoue pour $pkg_name"
    return 1
  }

  echo "OK: $pkg_name"
  echo ""
}

# --- Parsing des arguments ---
if [ $# -eq 0 ]; then
  # Pas d'argument: met a jour tous les paquets
  packages=$(list_packages)
  if [ -z "$packages" ]; then
    echo "Aucun paquet trouve dans $PKGS_DIR"
    exit 1
  fi

  echo "Mise a jour de tous les paquets:"
  echo "$packages" | sed 's/^/  /'
  echo ""

  failed=()
  for pkg in $packages; do
    if ! update_package "$pkg"; then
      failed+=("$pkg")
    fi
  done

  echo "=== Resume ==="
  if [ ${#failed[@]} -eq 0 ]; then
    echo "Tous les paquets mis a jour avec succes."
  else
    echo "Echec pour: ${failed[*]}"
    exit 1
  fi
elif [ $# -eq 1 ]; then
  update_package "$1"
elif [ $# -eq 2 ]; then
  update_package "$1" "$2"
else
  echo "Usage: $0 [nom-paquet] [version]"
  echo ""
  echo "Paquets disponibles dans pkgs/:"
  list_packages | sed 's/^/  /'
  exit 1
fi