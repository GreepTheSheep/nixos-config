{ config, lib, ... }:

{
  options.host = {
    containers.prometheus = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Prometheus node exporter containers for this host";
      };

      enableDgcmExporter = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Dgcm exporter container for this host";
      };
    };
  };

  config = lib.mkIf config.host.containers.prometheus.enable
  {
    virtualisation.oci-containers.containers = {
      node-exporter = {
        image = "quay.io/prometheus/node-exporter";
        volumes = [
          "/:/host:ro,rslave"
        ];
        capabilities = {
          SYS_ADMIN = true;
        };
        cmd = [
          "--path.rootfs=/host"
        ];
        environment = {
          TZ = "Europe/Paris";
        };
        dependsOn = [
          "caddy"
        ];
      };

      dgcm-exporter = lib.mkIf config.host.containers.prometheus.enableDgcmExporter {
        image = "nvcr.io/nvidia/k8s/dcgm-exporter";
        volumes = [
          "/dev/nvidia-caps:/dev/nvidia-caps"
          "/dev/nvidia0:/dev/nvidia0"
          "/dev/nvidiactl:/dev/nvidiactl"
          "/dev/nvidia-modeset:/dev/nvidia-modeset"
          "/dev/nvidia-uvm:/dev/nvidia-uvm"
          "/dev/nvidia-uvm-tools:/dev/nvidia-uvm-tools"
        ];
        capabilities = {
          SYS_ADMIN = true;
        };
        environment = {
          TZ = "Europe/Paris";
          NVIDIA_DRIVER_CAPABILITIES = "all";
          NVIDIA_VISIBLE_DEVICES = "all";
        };
        extraOptions = [ "--gpus=all" ];
        dependsOn = [
          "caddy"
        ];
      };
    };
  };
}