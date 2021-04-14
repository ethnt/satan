{ config, lib, pkgs, ... }:

with lib;

let cfg = config.satan.services.sabre;
in {
  options.satan.services.sabre = {
    enable = mkEnableOption "Enable Sabre WebDAV";
    path = mkOption {
      type = types.str;
      description = "Where on your file system the files sync to";
    };
    nginx.enable = mkEnableOption "Enable Nginx";
    nginx.host = mkOption { type = types.str; };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.sabre = {
      image = "stackd/sabre-dav";
      volumes = [ "${cfg.path}:/var/www/files" ];
      ports = [ "9050:80" ];
    };

    services.nginx = mkIf cfg.nginx.enable {
      virtualHosts."${cfg.nginx.host}" = {
        addSSL = true;
        enableACME = true;

        locations."/" = {
          proxyPass = "http://localhost:9050";
        };
      };
    };
  };
}
