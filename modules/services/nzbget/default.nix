{ config, lib, pkgs, ... }:

with lib;

let cfg = config.satan.services.nzbget;
in {
  options.satan.services.nzbget = {
    enable = mkEnableOption "Enable nzbget";

    nginx.enable = mkEnableOption "Enable Nginx";
    nginx.host = mkOption { type = types.str; };
  };

  config = mkIf cfg.enable {
    services.nzbget = { enable = true; };

    services.nginx = mkIf cfg.nginx.enable {
      virtualHosts."${cfg.nginx.host}" = {
        http2 = true;

        addSSL = true;
        enableACME = true;

        locations."/" = { proxyPass = "http://localhost:6789"; };
      };
    };
  };
}
