{ config, lib, pkgs, ... }:

{
  options.nixos = {
    server.samba = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable SMB file share.";
      };

      shares = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            name = lib.mkOption { type = lib.types.str; };
            path = lib.mkOption { type = lib.types.str; };
            browsable = lib.mkOption { type = lib.types.bool; default = true; };
            readonly = lib.mkOption { type = lib.types.bool; default = true; };
            guest = lib.mkOption { type = lib.types.bool; default = true; };
            users = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
            admins = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
            writelist = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
            comment = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
          };
        });
        example = [
          {
            name = "nas";
            path = "/mnt/data";
            readonly = true;
          }
        ];
        description = "List of shares.";
      };
    };
  };

  config = lib.mkIf config.nixos.server.samba.enable {
    services.samba = {
      enable = true;
      openFirewall = true;
      nsswins = false;
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = config.networking.hostName;
          "netbios name" = config.networking.hostName;
          "security" = "user";
          #"use sendfile" = "yes";
          #"max protocol" = "smb2";
          # note: localhost is the ipv6 localhost ::1
          "hosts allow" = "192.168.1. 127.0.0.1 localhost";
          "hosts deny" = "0.0.0.0/0";
          "guest account" = "nobody";
          "map to guest" = "bad user";

          "vfs objects" = "recycle";
          "recycle:repository" = ".recycle/%U";
          "recycle:keeptree" = "yes";
          "recycle:versions" = "yes";
          "recycle:touch" = "yes";
          "recycle:exclude" = "*.tmp *.temp *.o *.obj ~*";
          "recycle:exclude_dir" = ".recycle";
        };
      } // builtins.listToAttrs (map (share: {
        name = share.name;
        value = {
          path = share.path;
          browseable = if share.browsable then "yes" else "no";
          "read only" = if share.readonly then "yes" else "no";
          "guest ok" = if share.guest then "yes" else "no";
        } // lib.optionalAttrs (share.users != null) {
          "valid users" = share.users;
        } // lib.optionalAttrs (share.admins != null) {
          "admin users" = share.admins;
        } // lib.optionalAttrs (share.writelist != null) {
          "write list" = share.writelist;
        } // lib.optionalAttrs (share.comment != null) {
          comment = share.comment;
        };
      }) config.nixos.server.samba.shares);
    };

    sops.secrets."smb-share/user-greep" = {};

    system.activationScripts.sambaUsers.text = ''
      echo -e "$(cat ${
        config.sops.secrets."smb-share/user-greep".path
      })\n$(cat ${
        config.sops.secrets."smb-share/user-greep".path
      })" | ${pkgs.samba}/bin/smbpasswd -s -a greep || true
    '';

    systemd.services.smb-recycle-clean = {
      script = builtins.concatStringsSep "\n" (map (share: ''
        find ${share.path} -type d -name ".recycle" -exec rm -rf {}/\* \;
      '') config.nixos.server.samba.shares);
      serviceConfig.Type = "oneshot";
    };

    systemd.timers.smb-recycle-clean = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
      };
    };

    services.samba-wsdd = {
      enable = true;
      workgroup = "WORKGROUP";
      openFirewall = true;
      discovery = true;
    };
  };
}