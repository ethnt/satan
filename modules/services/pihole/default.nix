{ config, lib, pkgs, ... }:

with lib;

let cfg = config.satan.services.pihole;
in {
  options.satan.services.pihole = {
    enable = mkEnableOption "Enable PiHole";
  };
  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;

    virtualisation.oci-containers.containers.pihole = {
      image = "pihole/pihole:latest";
      ports =
        [ "53:53/tcp" "53:53/udp" "67:67/udp" "8000:80/tcp" "4433:443/tcp" ];
      environment = { TZ = "America/New_York"; };
      volumes =
        [ "/etc/pihole/:/etc/pihole/" "/etc/dnsmasq.d/:/etc/dnsmasq.d/" ];
      extraOptions = [ "--cap-add=NET_ADMIN" ];
      autoStart = true;
      log-driver = "journald";
    };

    networking.firewall = {
      allowedTCPPorts = [ 53 80 8000 4433 ];
      allowedUDPPorts = [ 53 67 ];
    };

    security.acme.acceptTerms = true;
    security.acme.email = "ethan.turkeltaub@hey.com";

    services.nginx = {
      enable = true;

      virtualHosts."pihole.satan.computer" = {
        addSSL = true;
        enableACME = true;

        root = "/var/www/pihole";

        locations."/" = { proxyPass = "http://localhost:8000"; };
      };
    };
  };
}
