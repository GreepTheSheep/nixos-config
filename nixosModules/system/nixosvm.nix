{ config, lib, ... }:

{
  options.nixos = {
    system.nixosvm = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable nixos vm.";
      };

      memorySize = lib.mkOption {
        type = lib.types.int;
        default = 8192;
        description = "RAM size of the VM in MiB";
      };

      cores = lib.mkOption {
        type = lib.types.int;
        default = 8;
        description = "Number of cores enabled in this VM";
      };
    };
  };

  config = lib.mkIf config.nixos.system.nixosvm.enable {
    systemd.tmpfiles.rules = [
      "d /opt/nixos-sandbox 0755 root root -"
    ];

    virtualisation.vmVariant = {
      virtualisation = {
        cores = config.nixos.system.nixosvm.cores;
        graphics = true;
        useEFIBoot = true;
        memorySize = config.nixos.system.nixosvm.memorySize;
        useSecureBoot = false;
      };
    };
  };
}