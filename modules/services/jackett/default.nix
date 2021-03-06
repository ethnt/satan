{ config, lib, pkgs, ... }:

with lib;

let cfg = config.satan.services.jackett;
in {
  options.satan.services.jackett = {
    enable = mkEnableOption "Enable Radarr";

    nginx = mkOption {
      type = types.submodule {
        options = {
          enable = mkEnableOption "Enable Nginx";
          host = mkOption { type = types.str; };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.jackett = {
      image = "ghcr.io/linuxserver/jackett";
      environment = {
        LOG_LEVEL = "info";
        TZ = "America/New_York";
      };
      dependsOn = [ "wireguard" ];
      extraOptions = [ "--net=container:wireguard" ];
      ports = [ "9117:9117" ];
      volumes = [ "/var/lib/jackett:/config" "/mnt:/mnt" ];
    };

    services.nginx = mkIf cfg.nginx.enable {
      virtualHosts."${cfg.nginx.host}" = {
        http2 = true;

        addSSL = true;
        enableACME = true;

        locations."/" = { proxyPass = "http://localhost:9117"; };
      };
    };
  };
}
