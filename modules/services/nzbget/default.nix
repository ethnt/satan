{ config, lib, pkgs, ... }:

with lib;

let cfg = config.satan.services.nzbget;
in {
  options.satan.services.nzbget = {
    enable = mkEnableOption "Enable nzbget";
    user = mkOption {
      description = "The user that runs nzbget";
      type = types.str;
      default = "root";
    };
    group = mkOption {
      description = "The group that runs nzbget";
      type = types.str;
      default = "root";
    };
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
    services.nzbget = {
      enable = true;
      user = cfg.user;
      group = cfg.group;
    };

    services.nginx = mkIf cfg.nginx.enable {
      virtualHosts."${cfg.nginx.host}" = {
        http2 = true;

        addSSL = true;
        enableACME = true;

        locations."/" = {
          proxyPass = "http://localhost:6789";
          proxyWebsockets = true;
        };
      };
    };
  };
}
