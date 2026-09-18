{ config, lib, inputs, ... }:

{
  options.nixos = {
    system.nixpkgs = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable nixpkgs overrides.";
      };
    };
  };

  config = lib.mkIf config.nixos.system.nixpkgs.enable {
    nixpkgs = {
      # Skips checks on openldap on i686 (does build failure recently, so we add this to skip)
      overlays = [
        (_: prev: {
          openldap = prev.openldap.overrideAttrs {
            doCheck = !prev.stdenv.hostPlatform.isi686;
          };
        })

        # Node.js 26 runs test-fs-cp-async-file-modes, which chmods the setuid
        # and setgid bits. Those chmods return EPERM inside the Nix build
        # sandbox, so the test can never pass and the whole nodejs build fails.
        # Upstream skips it too: https://github.com/NixOS/nixpkgs/issues/564449
        # Drop this overlay once nixpkgs-unstable carries the upstream fix.
        (_: prev: {
          nodejs-slim_26 = prev.nodejs-slim_26.overrideAttrs (old: {
            checkFlags = map (
              flag:
              if lib.hasPrefix "CI_SKIP_TESTS=" flag then
                "${flag},test-fs-cp-async-file-modes"
              else
                flag
            ) old.checkFlags;
          });
        })
      ];

      # Allow Electron 39.8.10 to build. Required for Bitwarden Desktop on NixOS 26.05
      config.permittedInsecurePackages = [
        "electron-39.8.10"
      ];
    };
  };
}