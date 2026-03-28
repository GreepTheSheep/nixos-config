{ config, lib, pkgs, inputs, ... }:

{
  options.nixos = {
    userEnvironment.game.vr = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable VR (OpenXR) using Monardo.";
      };

      enableMonardoHandTracking = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable Monardo Hand Tracking data. This requires additional setup, read https://wiki.nixos.org/wiki/VR#Hand_Tracking";
      };

      enableWiVRn = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable the WiVRn runtime. This will disable the default runtime Monardo.";
      };
    };
  };

  config = lib.mkIf config.nixos.userEnvironment.game.vr.enable {
    services.monado = lib.mkIf (!config.nixos.userEnvironment.game.vr.enableWiVRn) {
      enable = true;
      defaultRuntime = true; # Register as default OpenXR runtime
    };

    systemd.user.services.monado.environment = lib.mkIf (!config.nixos.userEnvironment.game.vr.enableWiVRn) {
      STEAMVR_LH_ENABLE = "1";
      XRT_COMPOSITOR_COMPUTE = "1";
      WMR_HANDTRACKING = lib.mkIf (!config.nixos.userEnvironment.game.vr.enableMonardoHandTracking) "0";
    };

    xdg.configFile."openxr/1/active_runtime.json".source = lib.mkIf (!config.nixos.userEnvironment.game.vr.enableWiVRn) "${pkgs.monado}/share/openxr/1/openxr_monado.json";

    services.wivrn = lib.mkIf config.nixos.userEnvironment.game.vr.enableWiVRn {
      enable = true;
      openFirewall = true;
      autoStart = true;
      package = lib.mkIf config.nixos.hardware.nvidiagpu.enable (pkgs.wivrn.override { cudaSupport = true; });
    };
  };
}