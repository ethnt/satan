{ config, lib, pkgs, ... }:
with lib;
let cfg = config.satan.services.xteve;
in {
  options.satan.services.xteve = {
    enable = mkEnableOption "Enable Xteve";

    envFile = mkOption {
      type = types.path;
    };

    nginx.enable = mkEnableOption "Enable Nginx";
    nginx.host = mkOption { type = types.str; };
  };

  config = mkIf cfg.enable {
    environment.etc."xteve/.env" = {
      source = cfg.envFile;
    };

    virtualisation.oci-containers.containers.xteve_lazystream = {
      image = "taylorbourne/xteve_lazystream";
      environment = { TZ = "America/New_York"; };
      ports = [ "34400:34400" ];
      volumes = [
        "/var/lib/xteve/.xteve:/xteve"
        "/var/lib/xteve/config:/config"
        "/var/lib/xteve/guide2go:/guide2go"
        "/var/lib/xteve/playlists:/playlists"
        "/tmp/xteve:/tmp/xteve"
      ];
      extraOptions = [ "--env-file=/etc/xteve/.env" ];
    };

    networking.firewall.allowedTCPPorts = [ 34400 ];
  };
}
