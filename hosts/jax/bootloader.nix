_:

{
  boot.loader.limine.style.interface.resolution = "3840x1080";

  nixos.system.bootloader = {
    timeout = 10;
  };
}