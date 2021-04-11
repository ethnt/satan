{ config, lib, pkgs, ... }:

with lib;

let cfg = config.satan.services.radarr;
in {
  options.satan.services.radarr = {
    enable = mkEnableOption "Enable Radarr";

    nginx.enable = mkEnableOption "Enable Nginx";
    nginx.host = mkOption { type = types.str; };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.radarr = {
      image = "ghcr.io/linuxserver/radarr";
      environment = {
        LOG_LEVEL = "info";
        TZ = "America/New_York";
      };
      ports = [ "7878:7878" ];
      extraOptions = [ "--network=htpc" ];
      volumes = [
        "/var/lib/radarr/.config/Radarr:/config"
        "/mnt/omnibus/media/movies:/movies"
        "/mnt/omnibus/nzbget/downloads/Movies:/downloads"
        "/mnt/omnibus/transmission/downloads:/transmission-downloads"
      ];
    };

    services.nginx = mkIf cfg.nginx.enable {
      virtualHosts."${cfg.nginx.host}" = {
        http2 = true;

        addSSL = true;
        enableACME = true;

        locations."/" = { proxyPass = "http://localhost:7878"; };
      };
    };
  };
}
