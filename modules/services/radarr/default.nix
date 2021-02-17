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
    services.radarr = {
      enable = true;
      openFirewall = true;
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
