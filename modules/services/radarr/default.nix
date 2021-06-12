{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.satan.services.radarr;
  port = "7878";
  containerBackend = config.virtualisation.oci-containers.backend;
in {
  options.satan.services.radarr = {
    enable = mkEnableOption "Enable Radarr";
    uid = mkOption {
      description = "UID of the user that runs Radarr";
      type = types.int;
      default = 0;
    };
    gid = mkOption {
      description = "GUID of the user that runs Radarr";
      type = types.int;
      default = 0;
    };
    configDir = mkOption {
      description = "Location of qBittorrent configuration directory on disk";
      type = types.str;
      default = "/var/lib/radarr";
    };
    extraVolumes = mkOption {
      description = "Extra directories to mount onto the container";
      type = types.listOf types.str;
      default = [ ];
    };
    nginx = mkOption {
      type = types.submodule {
        options = {
          enable = mkEnableOption "Enable Nginx";
          host = mkOption { type = types.str; };
        };
      };
    };
  };

  config = let
    uid = builtins.toString cfg.uid;
    gid = builtins.toString cfg.gid;
  in mkIf cfg.enable {
    virtualisation.oci-containers.containers.radarr = {
      image = "ghcr.io/linuxserver/radarr";
      environment = {
        PUID = uid;
        PGID = gid;
        LOG_LEVEL = "info";
        TZ = "America/New_York";
      };
      ports = [ "7878:${port}" ];
      volumes = [ "${cfg.configDir}:/config" ] ++ cfg.extraVolumes;
    };

    systemd.services."${containerBackend}-radarr-directories" = {
      serviceConfig.Type = "oneshot";

      wantedBy = [ "${containerBackend}-radarr.service" ];

      script = ''
        mkdir -p ${cfg.configDir}

        chown -R ${uid}:${gid} ${cfg.configDir}
      '';
    };

    services.nginx = mkIf cfg.nginx.enable {
      virtualHosts."${cfg.nginx.host}" = {
        http2 = true;

        addSSL = true;
        enableACME = true;

        locations."/" = { proxyPass = "http://localhost:${port}"; };
      };
    };
  };
}
