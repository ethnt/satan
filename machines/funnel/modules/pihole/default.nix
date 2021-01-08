{
  virtualisation.docker.enable = true;

  virtualisation.oci-containers.containers.pihole = {
    image = "pihole/pihole:latest";
    ports =
      [ "53:53/tcp" "53:53/udp" "67:67/udp" "8000:80/tcp" "4433:443/tcp" ];
    environment = { TZ = "America/New_York"; };
    volumes = [ "/etc/pihole/:/etc/pihole/" "/etc/dnsmasq.d/:/etc/dnsmasq.d/" ];
    extraOptions = [ "--cap-add=NET_ADMIN" ];
    autoStart = true;
    log-driver = "journald";
  };

  deployment.healthChecks = {
    cmd = [
      {
        cmd = [ "systemctl" "is-active" "docker-pihole.service" ];
        description = "Check if Pi-hole is running";
      }
      {
        cmd = [ "dig" "github.com" "@127.0.0.1" "-p" "53" ];
        description = "Check if Pi-hole can resolve domains";
      }
    ];

    http = [{
      scheme = "http";
      port = 8000;
      path = "/admin";
      description = "Check if Pi-hole admin is accessible";
    }];
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
}
