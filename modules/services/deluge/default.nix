{ config, lib, pkgs, ... }:

with lib;

let cfg = config.satan.services.deluge;
in {
  options.satan.services.deluge = {
    enable = mkEnableOption "Enable Deluge";

    nginx.enable = mkEnableOption "Enable Nginx";
    nginx.host = mkOption { type = types.str; };
  };

  config = mkIf cfg.enable {
    services.deluge = {
      enable = true;
      # openFirewall = true;
      web = {
        enable = true;
        port = 8112;
        # openFirewall = true;
      };
    };

    systemd.services."delugeweb" = {
      bindsTo = [ "wg.service" ];
      after = [ "wg.service" ];
      unitConfig.JoinsNamespaceOf = "netns@wg.service";
      serviceConfig.PrivateNetwork = true;
    };

    systemd.services."deluged" = {
      bindsTo = [ "wg.service" ];
      after = [ "wg.service" ];
      unitConfig.JoinsNamespaceOf = "netns@wg.service";
      serviceConfig.PrivateNetwork = true;
    };

    services.nginx = mkIf cfg.nginx.enable {
      virtualHosts."${cfg.nginx.host}" = {
        http2 = true;

        addSSL = true;
        enableACME = true;

        locations."/" = { proxyPass = "http://localhost:8112"; };
      };
    };
  };
}
