{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.satan.services.qbittorrent;
  port = "8080";
  containerBackend = config.virtualisation.oci-containers.backend;
in {
  options.satan.services.qbittorrent = {
    enable = mkEnableOption "Enable qBittorrent";
    uid = mkOption {
      description = "UID of the user that runs qBittorrent";
      type = types.int;
      default = 0;
    };
    gid = mkOption {
      description = "GUID of the user that runs qBittorrent";
      type = types.int;
      default = 0;
    };
    configDir = mkOption {
      description = "Location of qBittorrent configuration directory on disk";
      type = types.str;
      default = "/var/lib/qbittorrent";
    };
    downloadsDir = mkOption {
      description = "Location of qBittorrent downloads directory on disk";
      type = types.str;
      default = "/data/qbittorrent";
    };
    extraVolumes = mkOption {
      description = "Extra directories to mount onto the container";
      type = types.listOf types.str;
      default = [ ];
    };
    wireguard = mkOption {
      type = types.submodule {
        options = { enable = mkEnableOption "Enable Wireguard"; };
      };
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
    virtualisation.oci-containers.containers.qbittorrent = mkMerge [
      {
        image = "ghcr.io/linuxserver/qbittorrent";
        environment = {
          PUID = uid;
          PGID = gid;
          WEBUI_PORT = port;
          TZ = "America/New_York";
        };

        volumes =
          [ "${cfg.configDir}:/config" "${cfg.downloadsDir}:/downloads" ]
          ++ cfg.extraVolumes;
      }
      (mkIf cfg.wireguard.enable {
        extraOptions = [ "--net=container:wireguard" ];
        dependsOn = [ "wireguard" ];
      })
    ];

    systemd.services."${containerBackend}-qbittorrent-directories" = {
      serviceConfig.Type = "oneshot";

      wantedBy = [ "${containerBackend}-qbittorrent.service" ];

      script = ''
        mkdir -p ${cfg.configDir}
        mkdir -p ${cfg.downloadsDir}

        chown -R ${uid}:${gid} ${cfg.configDir}
        chown -R ${uid}:${gid} ${cfg.downloadsDir}
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
