{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.satan.services.transmission;
  # etc."transmission/settings.json" = {
  #   source = ../../../machines/barbossa/etc/transmission.json;
  # };
in {
  options.satan.services.transmission = {
    enable = mkEnableOption "Enable Transmission";

    settingsPath = mkOption { };

    nginx.enable = mkEnableOption "Enable Nginx";
    nginx.host = mkOption { type = types.str; };
  };

  config = mkIf cfg.enable {
    environment.etc."transmission/settings.json" = { source = cfg.settingsPath; };

    virtualisation.oci-containers.containers.transmission = {
      autoStart = true;
      image = "linuxserver/transmission:version-3.00-r2";

      environment = {
        "PUID" = "1001";
        "PGID" = "1001";
        "TZ" = "America/New_York";
      };

      dependsOn = [ "wireguard" ];
      ports = [ "9091:9091" ];

      extraOptions = [ "--net=container:wireguard" ];
      volumes = [
        "/var/lib/transmission:/config"
        "/mnt/omnibus/transmission/downloads:/downloads"
        "/mnt/omnibus/transmission/incomplete:/incomplete"
        "/mnt/omnibus/transmission/watch:/watch"
        "/etc/transmission/settings.json:/config/settings.json:ro"
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
