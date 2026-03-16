{ config, lib, ... }:

{
  imports = [
    ./boot.nix
    ./bootloader.nix
    ./clamav.nix
    ./cloudmount.nix
    ./cron.nix
    ./dbus.nix
    ./earlyoom.nix
    ./firewall.nix
    ./locals.nix
    ./motd.nix
    ./networking.nix
    ./nh.nix
    ./nix-ld.nix
    ./nixos.nix
    ./nixosvm.nix
    ./powermanagement.nix
    ./secureboot.nix
    ./sops.nix
    ./ssh.nix
    ./user.nix
  ];

  options.nixos = {
    system = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable system modules bundle.";
      };
    };
  };

  config = lib.mkIf config.nixos.system.enable {
    nixos.system = {
      boot.enable = true;
      bootloader.enable = true;
      clamav.enable = true;
      cloudmount.enable = lib.mkDefault false;
      cron.enable = true;
      dbus.enable = true;
      earlyoom.enable = true;
      firewall.enable = true;
      locals.enable = true;
      motd.enable = lib.mkDefault false;
      networking.enable = true;
      nh.enable = true;
      nix-ld.enable = true;
      nixos.enable = true;
      nixosvm.enable = lib.mkDefault false;
      powermanagement.enable = true;
      secureboot.enable = lib.mkDefault false;
      sops.enable = true;
      ssh.enable = true;
      user.enable = true;
    };
  };
}