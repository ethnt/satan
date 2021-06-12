{ config, lib, pkgs, ... }:

with lib;

let cfg = config.satan.services.wireguard;
in {
  options.satan.services.wireguard = {
    enable = mkEnableOption "Enable Wireguard";

  };

  config = mkIf cfg.enable {
    networking = {
      nat = {
        enable = true;
        externalInterface = "eno1";
        internalInterfaces = [ "wg0" ];
      };

      firewall.allowedUDPPorts = [ 51820 ];

      # wireguard.interfaces.wg0 = {
      #   ips = [ cfg.ip ];
      #   listenPort = cfg.listenPort;

      #   privateKeyFile = cfg.privateKeyFile;

      #   peers = cfg.peers;
      # };
    };

    systemd.services."netns@" = {
      description = "%I network namespace";
      before = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        PrivateNetwork = true;
        ExecStart = "${
            pkgs.writers.writeDash "netns-up" ''
              ${pkgs.iproute}/bin/ip netns add $1
              ${pkgs.utillinux}/bin/umount /var/run/netns/$1
              ${pkgs.utillinux}/bin/mount --bind /proc/self/ns/net /var/run/netns/$1
            ''
          } %I";
        ExecStop = "${pkgs.iproute}/bin/ip netns del %I";
      };
    };

    systemd.services.wg = {
      description = "wg network interface";
      bindsTo = [ "netns@wg.service" ];
      requires = [ "network-online.target" ];
      after = [ "netns@wg.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writers.writeDash "wg-up" ''
          ${pkgs.iproute}/bin/ip link add wg type wireguard
          ${pkgs.wireguard}/bin/wg set wg \
            private-key w4J3Pdi1ZJdBfJH6g/506G3a1FekkjZyDlICL72iBqU= \
            peer +/HYwELAaww6XTtPmvf3Hr8NqLIr69YNUpAMBvWJiGw= \
            allowed-ips 0.0.0.0/0,::/0 \
            endpoint 86.106.143.15:3214
          ${pkgs.iproute}/bin/ip link set wg netns wg up
          ${pkgs.iproute}/bin/ip -n wg address add 10.72.166.76/32 dev wg
          ${pkgs.iproute}/bin/ip -n wg -6 address add fc00:bbbb:bbbb:bb01::9:a64b/128 dev wg
          ${pkgs.iproute}/bin/ip -n wg route add default dev wg
          ${pkgs.iproute}/bin/ip -n wg -6 route add default dev wg
        '';
        ExecStop = pkgs.writers.writeDash "wg-down" ''
          ${pkgs.iproute}/bin/ip -n wg link del wg
          ${pkgs.iproute}/bin/ip -n wg route del default dev wg
        '';
      };
    };
  };
}
