{ config, lib, pkgs, ... }:

with lib;

let cfg = config.satan.services.unifi;
in {
  options.satan.services.unifi = {
    enable = mkEnableOption "Enable the UniFi Controller";
  };

  config = mkIf cfg.enable {
    virtualisation.docker.enable = true;

    virtualisation.oci-containers.containers.unifi = {
      image = "jacobalberty/unifi:latest";
      ports = [ "8443:8443" "8080:8080" "3478:3478/udp" ];
      environment = { TZ = "America/New_York"; };
      volumes = [ "/etc/unifi:/unifi" ];
      autoStart = true;
    };

    networking.firewall = {
      allowedTCPPorts = [ 8443 8080 ];
      allowedUDPPorts = [ 8443 8080 3478 ];
    };
  };
}
