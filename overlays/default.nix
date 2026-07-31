# Overlay exposant les paquets locaux nxapi (CLI et app Electron)
final: prev: {
  nxapi = final.callPackage ../pkgs/nxapi/default.nix { };
  nxapi-electron = final.callPackage ../pkgs/nxapi/electron.nix { };
}