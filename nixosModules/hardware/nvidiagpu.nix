{ config, lib, pkgs, ...}:

{
  options.nixos = {
    hardware.nvidiagpu = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Nvidia GPU support.";
      };
    };
  };

  config = lib.mkIf config.nixos.hardware.nvidiagpu.enable {
    boot.initrd.kernelModules = [ "nvidia" ];

    # In VM builds, the nvidia kernel module is not available, so disable
    # all nvidia-specific settings that would cause the build to fail.
    virtualisation.vmVariant = {
      boot.initrd.kernelModules = lib.mkForce (
        lib.filter (m: m != "nvidia") config.boot.initrd.kernelModules
      );
      services.xserver.videoDrivers = lib.mkForce [ ];
      hardware.nvidia.modesetting.enable = lib.mkForce false;
    };

    # Make sure opengl is enabled
    hardware.graphics.enable = true;

    # Tell Xorg to use the nvidia driver
    services.xserver = {
      videoDrivers = [ "nvidia" ];
    };

    hardware.nvidia = {

      # Modesetting is needed for most wayland compositors
      modesetting.enable = true;

      # Use the open source version of the kernel module
      # Only available on driver 515.43.04+
      open = true;

      # Enable the nvidia settings menu
      nvidiaSettings = true;

      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      package = config.boot.kernelPackages.nvidiaPackages.stable;

      powerManagement.enable = true;
    };

    environment.sessionVariables = {
      # If the cursor becomes invisible
      WLR_NO_HARDWARE_CURSORS = "1";

      # Hint electron apps to use wayland
      NIXOS_OZONE_WL = "1";
    };

    environment.systemPackages = with pkgs; [
      nvtopPackages.nvidia
    ];
  };
}