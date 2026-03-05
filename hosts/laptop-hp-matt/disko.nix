{ disk ? "/dev/sda", luks ? false, ... }:

let
  btrfsContent = {
    type = "btrfs";
    extraArgs = [ "-L" "nixos" "-f" ];
    subvolumes = {
      "@" = {
        mountpoint = "/";
        mountOptions = [ "compress-force=zstd:2" "noatime" "space_cache=v2" ];
      };
      "@home" = {
        mountpoint = "/home";
        mountOptions = [ "compress-force=zstd:2" "noatime" "space_cache=v2" ];
      };
    };
  };

  rootContent = if luks then {
    type = "luks";
    name = "cryptroot";
    passwordFile = "/tmp/luks-password";
    settings.allowDiscards = true;
    content = btrfsContent;
  } else btrfsContent;
in

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
            content = rootContent;
          };
        };
      };
    };
  };
}
