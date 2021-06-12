{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.satan.services.sonarr;
  port = "8989";
  containerBackend = config.virtualisation.oci-containers.backend;
in {
  options.satan.services.sonarr = {
    enable = mkEnableOption "Enable Sonarr";
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
      default = "/var/lib/sonarr";
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
    virtualisation.oci-containers.containers.sonarr = {
      image = "ghcr.io/linuxserver/sonarr";
      environment = {
        PUID = uid;
        PGID = gid;
        LOG_LEVEL = "info";
        TZ = "America/New_York";
      };
      ports = [ "${port}:8989" ];
      volumes = [ "${cfg.configDir}:/config" ] ++ cfg.extraVolumes;
    };

    systemd.services."${containerBackend}-sonarr-directories" = {
      serviceConfig.Type = "oneshot";

      wantedBy = [ "${containerBackend}-sonarr.service" ];

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
