{ config, lib, pkgs, ... }:

with lib;

let cfg = config.satan.services.wireguard;
in {
  options.satan.services.wireguard = {
    enable = mkEnableOption "Enable Wireguard";
    listenPort = mkOption {
      type = types.port;
      default = 51820;
    };
    externalInterface = mkOption {
      type = types.str;
      default = "eth0";
    };
    privateKeyFile = mkOption { };
    ip = mkOption {
      type = types.str;
      description = "IP and mask";
    };
    peers = mkOption { };
  };

  config = mkIf cfg.enable {
    networking = {
      nat = {
        enable = true;
        externalInterface = cfg.externalInterface;
        internalInterfaces = [ "wg0" ];
      };

      firewall = { allowedUDPPorts = [ cfg.listenPort ]; };

      wireguard.interfaces.wg0 = {
        ips = [ cfg.ip ];
        listenPort = cfg.listenPort;

        privateKeyFile = cfg.privateKeyFile;

        peers = cfg.peers;
      };
    };
  };
}
