{ config, lib, pkgs, ... }:

with lib;

let cfg = config.satan.services.overseerr;
in {
  options.satan.services.overseerr = {
    enable = mkEnableOption "Enable Overseerr";

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
    virtualisation.oci-containers = {
      containers = {
        overseerr = {
          image = "sctx/overseerr:latest";
          environment = {
            LOG_LEVEL = "info";
            TZ = "America/New_York";
          };
          ports = [ "5055:5055" ];
          volumes = [ "/var/lib/overseerr/config:/app/config" ];
        };
      };
    };

    services.nginx = mkIf cfg.nginx.enable {
      virtualHosts."${cfg.nginx.host}" = {
        http2 = true;

        addSSL = true;
        enableACME = true;

        locations."/" = { proxyPass = "http://localhost:5055"; };
      };
    };
  };
}
