{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.satan.services.transmission;
  etc."transmission/settings.json" = {
    source = ../../../machines/barbossa/etc/transmission.json;
  };
in {
  options.satan.services.transmission = {
    enable = mkEnableOption "Enable Transmission";

    authentication.username = mkOption {};
    authentication.password = mkOption {};

    nginx.enable = mkEnableOption "Enable Nginx";
    nginx.host = mkOption { type = types.str; };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 51413 ];
    networking.firewall.allowedUDPPorts = [ 51413 ];

    virtualisation.oci-containers.containers.transmission = {
      autoStart = true;
      image = "linuxserver/transmission:version-3.00-r2";

      environment = {
        "PUID" = "1001";
        "PGID" = "1001";
        "TZ" = "America/New_York";
        "USERNAME" = cfg.authentication.username;
        "PASSWORD" = cfg.authentication.password;
      };

      dependsOn = [ "wireguard" ];
      ports = [ "9091/9091" ];

      extraOptions = [ "--net=container:wireguard" ];
      volumes = [
        "/var/lib/transmission:/config"
        "/mnt/omnibus/transmission/downloads:/downloads"
        "/mnt/omnibus/transmission/incomplete:/incomplete"
        "/mnt/omnibus/transmission/watch:/watch"
        "${etc."transmission/settings.json".source}:/config/settings.json:ro"
      ];
    };

    services.nginx = mkIf cfg.nginx.enable {
      virtualHosts."${cfg.nginx.host}" = {
        http2 = true;

        addSSL = true;
        enableACME = true;

        locations."/" = { proxyPass = "http://localhost:9091"; };
      };
    };
  };
}
