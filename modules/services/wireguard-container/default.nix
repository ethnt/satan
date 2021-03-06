{ config, lib, pkgs, ... }:

with lib;

let cfg = config.satan.services.wireguard-container;
in {
  options.satan.services.wireguard-container = {
    enable = mkEnableOption "Enable Wireguard";
  };

  config = mkIf cfg.enable {
    # boot.extraModulePackages = [ config.boot.kernelPackages.wireguard ];

    environment.systemPackages = with pkgs; [ wireguard ];

    networking.firewall.allowedUDPPorts = [ 51820 ];

    virtualisation.oci-containers.containers.wireguard = {
      autoStart = true;
      image = "linuxserver/wireguard:version-v1.0.20210315";

      environment = {
        "PUID" = "1001";
        "PGID" = "1001";
      };

      ports = [
        "9091:9091"
        "9117:9117"
        "6881:6881"
        "6881:6881/udp"
        "8080:8080"
        "6767:6767"
      ];

      extraOptions = [
        "--network=htpc"
        "--cap-add=NET_ADMIN"
        "--cap-add=SYS_MODULE"
        "--sysctl=net.ipv4.conf.all.src_valid_mark=1"
      ];

      volumes = [
        "/run/booted-system/kernel-modules/lib/modules:/lib/modules:ro"
        "${config.deployment.keys.wireguard-wg0.path}:/config/wg0.conf:ro"
      ];
    };
  };
}
