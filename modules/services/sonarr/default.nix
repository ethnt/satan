{ config, lib, pkgs, ... }:

with lib;

let cfg = config.satan.services.sonarr;
in {
  options.satan.services.sonarr = {
    enable = mkEnableOption "Enable Sonarr";

    nginx.enable = mkEnableOption "Enable Nginx";
    nginx.host = mkOption { type = types.str; };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.sonarr = {
      image = "ghcr.io/linuxserver/sonarr";
      environment = {
        LOG_LEVEL = "info";
        TZ = "America/New_York";
      };
      ports = [ "8989:8989" ];
      volumes = [
        "/var/lib/sonarr/.config/NzbDrone:/config"
        "/mnt/omnibus/media/tv:/tv"
        "/mnt/omnibus/nzbget/downloads/TV\ Shows:/downloads"
        "/mnt/omnibus/transmission/downloads:/transmission-downloads"
      ];
    };

    services.nginx = mkIf cfg.nginx.enable {
      virtualHosts."${cfg.nginx.host}" = {
        http2 = true;

        addSSL = true;
        enableACME = true;

        locations."/" = { proxyPass = "http://localhost:8989"; };
      };
    };
  };
}
