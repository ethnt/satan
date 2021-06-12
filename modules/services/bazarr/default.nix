{ config, lib, pkgs, ... }:

with lib;

let cfg = config.satan.services.bazarr;
in {
  options.satan.services.bazarr = {
    enable = mkEnableOption "Enable bazarr";

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
    virtualisation.oci-containers.containers.bazarr = {
      image = "ghcr.io/linuxserver/bazarr";
      environment = {
        LOG_LEVEL = "info";
        TZ = "America/New_York";
      };
      extraOptions = [ "--net=container:wireguard" ];
      dependsOn = [ "wireguard" ];
      ports = [ "6767:6767" ];
      volumes = [
        "/var/lib/sonarr:/config"
        "/mnt/omnibus/media/tv:/tv"
        "/mnt/omnibus/media/movies:/movies"
      ];
    };

    services.nginx = mkIf cfg.nginx.enable {
      virtualHosts."${cfg.nginx.host}" = {
        http2 = true;

        addSSL = true;
        enableACME = true;

        locations."/" = { proxyPass = "http://localhost:6767"; };
      };
    };
  };
}
