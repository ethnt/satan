{ config, lib, pkgs, ... }:

with lib;

let cfg = config.satan.services.graylog;
in {
  options.satan.services.graylog = {
    enable = mkEnableOption "Enable Graylog";
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
    services.mongodb.enable = true;
    services.elasticsearch = {
      enable = true;
      listenAddress = "127.0.0.1";
    };

    networking.firewall = {
      allowedTCPPorts = [ 5144 9000 ];
      allowedUDPPorts = [ 5144 9000 ];
    };

    services.graylog = {
      enable = true;
      elasticsearchHosts =
        [ "http://127.0.0.1:9200" ];

      extraConfig = ''
        http_bind_address = 0.0.0.0:9000
        http_publish_uri = https://${cfg.nginx.host}/
      '';

      nodeIdFile = "/var/lib/graylog/node-id";

      passwordSecret =
        "KEt9eS1KFs6k3Fdxlm0FKVeWRFteFj9soB1MnnGOOFBn3bZbl1P8kW3Nvotalu705MinopxoFme3TpauD11Ca3J2ztz7OYwg";

      rootPasswordSha2 =
        "6246094315aa2c47a7ab6a860d8c52e7014aaca164b0caa21d2df105682473f6";
    };

    services.nginx = mkIf cfg.nginx.enable {
      virtualHosts."${cfg.nginx.host}" = {
        http2 = true;

        addSSL = true;
        enableACME = true;

        locations."/" = { proxyPass = "http://localhost:9000"; };
      };
    };
  };
}
