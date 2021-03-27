{ config, lib, pkgs, ... }:

with lib;

let cfg = config.satan.services.grafana;
in {
  options.satan.services.grafana = {
    enable = mkEnableOption "Enable Grafana";

    addr = mkOption {
      type = types.str;
      default = "";
    };

    domain = mkOption {
      type = types.str;
      default = "localhost";
    };

    port = mkOption {
      type = types.int;
      default = 3000;
    };

    protocol = mkOption {
      type = types.str;
      default = "http";
    };

    nginx.enable = mkEnableOption "Enable Nginx";

    nginx.host = mkOption { type = types.str; };
  };

  config = mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.port ];
    };

    services.grafana = {
      enable = true;
      addr = cfg.addr;
      domain = cfg.domain;
      port = cfg.port;
      protocol = cfg.protocol;
    };

    services.nginx = mkIf cfg.nginx.enable {
      virtualHosts."${cfg.nginx.host}" = {
        http2 = true;

        addSSL = true;
        enableACME = true;

        # FIXME: proxyPass should not be hardcoded like this, but can't figure out how to coerce int to string for port
        locations."/" = { proxyPass = "http://localhost:3000"; };
      };
    };
  };
}
