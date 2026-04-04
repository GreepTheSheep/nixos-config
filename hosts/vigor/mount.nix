_:

{
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/ee904141-f052-4f9b-907b-9a371fcf6617";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/5207-1CFF";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/ee904141-f052-4f9b-907b-9a371fcf6617";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/ee904141-f052-4f9b-907b-9a371fcf6617";
      fsType = "btrfs";
      options = [ "subvol=@nix" ];
    };

  fileSystems."/var/lib/docker" =
    { device = "/dev/disk/by-uuid/ee904141-f052-4f9b-907b-9a371fcf6617";
      fsType = "btrfs";
      options = [ "subvol=@docker" ];
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-uuid/ee904141-f052-4f9b-907b-9a371fcf6617";
      fsType = "btrfs";
      options = [ "subvol=@log" ];
    };

  fileSystems."/mnt/data" =
    { device = "/dev/disk/by-uuid/5d3130b2-c128-4124-a0aa-2757637454ec";
      fsType = "ext4";
      options = [ "defaults" "noatime" ];
    };

  fileSystems."/mnt/localdata" =
    { device = "/dev/disk/by-uuid/2835dc6b-11c8-4cdf-870a-f456eeaedc9d";
      fsType = "ext4";
      options = [ "defaults" "nofail" "noatime" ];
    };

  swapDevices = [
    {
      device = "/swapfile";
      size = 10240;
      priority = 10;
    }
  ];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };
}
