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
    services.sonarr = {
      enable = true;
      openFirewall = true;
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
