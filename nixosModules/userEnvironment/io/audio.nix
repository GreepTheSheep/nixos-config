{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.nixos = {
    userEnvironment.io.audio = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable audio support";
      };
    };
  };

  config = lib.mkIf config.nixos.userEnvironment.io.audio.enable {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
      raopOpenFirewall = true;

      extraConfig.pipewire-pulse = {
        "pulse.rules" = [
          {
            matches = [
              {
                "application.process.binary" = "wine64-preloader";
              }
            ];

            actions = {
              update-props = {
                pulse.min.quantum = "1024/48000";
              };
            };
          }
        ];
      };

      extraConfig.pipewire = {
        # Paramètres globaux PipeWire pour réduire les glitches
        "10-audio-quality" = {
          "context.properties" = {
            # Augmente la taille du buffer pour éviter les coupures lors de pics CPU
            "default.clock.rate" = 48000;
            "default.clock.quantum" = 2048;  # Buffer plus grand = moins de glitches
            "default.clock.min-quantum" = 1024;
            "default.clock.max-quantum" = 8192;

            # Priorité temps réel pour l'audio
            "core.daemon" = true;
            "core.name" = "pipewire-0";
          };

          "context.modules" = [
            {
              name = "libpipewire-module-rtkit";
              args = {
                "nice.level" = -11;  # Priorité élevée pour l'audio
                "rt.prio" = 88;
                "rt.time.soft" = 2000000;
                "rt.time.hard" = 2000000;
              };
              flags = [ "ifexists" "nofail" ];
            }
          ];
        };

        # AirPlay avec latence augmentée
        "10-airplay" = {
          "context.modules" = [
            {
              name = "libpipewire-module-raop-discover";
              args = {
                "raop.latency.ms" = 500;  # Augmente la latence pour AirPlay
              };
            }
          ];
        };
      };

      wireplumber.extraConfig = {
        "10-bluez" = {
          "monitor.bluez.properties" = {
            "bluez5.enable-sbc-xq" = true;
            "bluez5.enable-msbc" = true;
            "bluez5.enable-hw-volume" = true;

            # Codecs audio de meilleure qualité
            "bluez5.codecs" = [ "sbc" "sbc_xq" "aac" "ldac" "aptx" "aptx_hd" ];

            # Ne pas forcer les profils HSP/HFP - ils seront activés automatiquement
            # uniquement quand une application VoIP (Discord, etc.) utilise le microphone
            "bluez5.headset-roles" = [ "hfp_ag" "hsp_ag" ];

            # Profil par défaut : A2DP (haute qualité stéréo)
            "bluez5.auto-connect" = [ "a2dp_sink" ];

            # Augmente la latence Bluetooth pour éviter les glitches
            # Valeur plus élevée = plus de buffer = moins de coupures
            "bluez5.a2dp.latency-ms" = 300;
          };
        };

        # Basculement automatique intelligent entre A2DP et HSP/HFP
        "51-bluez-autoswitch" = {
          "monitor.bluez.rules" = [
            {
              matches = [
                {
                  # S'applique à tous les périphériques Bluetooth
                  "device.name" = "~bluez_card.*";
                }
              ];
              actions = {
                update-props = {
                  # Profil par défaut : A2DP (audio haute qualité)
                  "bluez5.auto-connect" = [ "a2dp_sink" ];
                  # Bascule vers HFP uniquement si une source audio est requise (appel VoIP)
                  "bluez5.profile" = "auto";

                  # Buffer plus grand pour Bluetooth
                  "api.alsa.period-size" = 2048;
                  "api.alsa.headroom" = 8192;
                };
              };
            }
          ];
        };
      };
    };

    environment.systemPackages = with pkgs; [
      pulseaudio
      alsa-plugins
      alsa-utils
      alsa-tools
      alsa-lib
      fftw
    ];
  };
}