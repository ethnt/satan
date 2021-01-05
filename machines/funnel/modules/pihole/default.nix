{
  virtualisation.docker.enable = true;

  virtualisation.oci-containers.containers.pihole = {
    image = "pihole/pihole:latest";
    ports = [ "53:53/tcp" "53:53/udp" "67:67/udp" "80:80/tcp" "443:443/tcp" ];
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
      port = 80;
      path = "/admin";
      description = "Check if Pi-hole admin is accessible";
    }];
  };
}
