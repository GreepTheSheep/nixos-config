{
  config,
  lib,
  inputs,
  ...
}:

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
      overlays = [
        # ltrace 0.7.91 fails its demangle test cases with recent
        # binutils/GCC (C++ symbol demangling is broken), which makes the
        # whole build fail. Drop this overlay once upstream is fixed.
        (_: prev: {
          ltrace = prev.ltrace.overrideAttrs { doCheck = false; };
        })

        # nixpkgs' aggregateModules assumes every external module has a
        # .ko.cer certificate. VMware, vendor-reset and sc0710 don't, which
        # makes the xargs/cat step fail. Skip missing certificates instead.
        (_: prev: {
          aggregateModules =
            modules:
            prev.buildEnv {
              name = "kernel-modules";
              paths = modules;
              pathsToLink = [
                "/lib/modules"
                "/etc/depmod.d"
              ];
              postBuild = ''
                source ${prev.stdenvNoCC}/setup

                if ! test -d "$out/lib/modules"; then
                  echo "No modules found."
                  # To support a kernel without modules
                  exit 0
                fi

                kernelVersion=$(cd $out/lib/modules && ls -d *)
                if test "$(echo $kernelVersion | wc -w)" != 1; then
                   echo "inconsistent kernel versions: $kernelVersion"
                   exit 1
                fi

                echo "kernel version is $kernelVersion"

                shopt -s extglob

                # Regenerate the depmod map files.  Be sure to pass an explicit
                # kernel version number, otherwise depmod will use `uname -r'.
                if test -w $out/lib/modules/$kernelVersion; then
                    rm -f $out/lib/modules/$kernelVersion/modules.!(builtin*|order*|cer)
                    ${prev.buildPackages.kmod}/bin/depmod -b $out -C $out/etc/depmod.d -a $kernelVersion
                    cd -- "$out/lib/modules/$kernelVersion"

                    # Merge the single-module certificates for external modules.
                    cp --no-preserve=mode,ownership --remove-destination -- "$(readlink -f modules.cer)" modules.cer
                    sed "1,$(wc -l < modules.order)d; s/\.ko.*/.ko.cer/" modules.dep \
                        | while IFS= read -r cert; do
                            if [ -e "$cert" ]; then
                              cat "$cert" >> modules.cer
                            fi
                          done
                fi
              '';
            };
        })
      ];

      # Allow Electron 39.8.10 to build. Required for Bitwarden Desktop on NixOS 26.05
      config.permittedInsecurePackages = [
        "electron-39.8.10"
      ];
    };
  };
}
