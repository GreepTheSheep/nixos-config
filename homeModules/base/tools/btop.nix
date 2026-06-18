{ config, lib, pkgs, osConfig, ... }:

{
  options.homeManager = {
    base.tools.btop = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable btop.";
      };

      enableGPUSupport = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable GPU support. Uses btop-cuda or btop-rocm (depending of the `osConfig.nixos.hardware.*gpu` configuration) to display GPU graph.";
      };
    };
  };

  config = lib.mkIf config.homeManager.base.tools.btop.enable {
    programs.btop = {
      enable = true;
      package = lib.mkMerge [
        (lib.mkIf config.homeManager.base.tools.btop.enableGPUSupport (lib.mkMerge [
          (lib.mkIf osConfig.nixos.hardware.nvidiagpu.enable pkgs.btop-cuda)
          (lib.mkIf (!osConfig.nixos.hardware.nvidiagpu.enable) (lib.mkMerge [
            (lib.mkIf osConfig.nixos.hardware.amdgpu.enable pkgs.btop-rocm)
            (lib.mkIf (!osConfig.nixos.hardware.amdgpu.enable) pkgs.btop)
          ]))
        ]))
        (lib.mkIf (!config.homeManager.base.tools.btop.enableGPUSupport) pkgs.btop)
      ];
    };

    #catppuccin.btop.enable = lib.mkIf config.homeManager.theme.catppuccin.enable true;
  };
}