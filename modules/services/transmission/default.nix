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

    nginx.enable = mkEnableOption "Enable Nginx";
    nginx.host = mkOption { type = types.str; };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.transmission = {
      image = "ghcr.io/linuxserver/transmission";
      environment = {
        TZ = "America/New_York";
        USER = "ethan";
        PASS = "13201";
      };
      ports = [ "9091:9091" "51413:51413" "51413:51413/udp" ];
      volumes = [
        "/var/lib/transmission:/config"
        "/mnt/omnibus/transmission/downloads:/downloads"
        "/mnt/omnibus/transmission/watch:/watch"
        "${etc."transmission/settings.json".source}:/config/settings.json:ro"
      ];
    };

    # systemd.services."transmission" = {
    #   bindsTo = [ "wg.service" ];
    #   after = [ "wg.service" ];
    #   unitConfig.JoinsNamespaceOf = "netns@wg.service";
    #   serviceConfig.PrivateNetwork = true;
    # };

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
