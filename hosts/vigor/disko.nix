{ disk ? "/dev/sda", ... }:

{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = disk;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "fmask=0022" "dmask=0022" ];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-L" "nixos" "-f" ];
              subvolumes = {
                "@" = {
                  mountpoint = "/";
                  mountOptions = [ "subvol=@" "noatime" "compress=zstd:2" "space_cache=v2" ];
                };
                "@home" = {
                  mountpoint = "/home";
                  mountOptions = [ "subvol=@home" "noatime" "compress=zstd:2" "space_cache=v2" ];
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "subvol=@nix" "noatime" "space_cache=v2" ];
                };
                "@docker" = {
                  mountpoint = "/var/lib/docker";
                  mountOptions = [ "subvol=@docker" "noatime" "space_cache=v2" ];
                };
                "@log" = {
                  mountpoint = "/var/log";
                  mountOptions = [ "subvol=@log" "noatime" "compress=zstd:6" "space_cache=v2" ];
                };
              };
            };
          };
        };
      };
    };
  };
}
