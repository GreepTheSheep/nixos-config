_:

{
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/1204b7ab-1366-46c5-8989-be545186b3b5";
      fsType = "btrfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/C1F9-4D48";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices = [ { device = "/dev/disk/by-uuid/ffd81d86-209f-472c-870c-8f56ff19b40c"; } ];
}