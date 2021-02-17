{ config, lib, pkgs, ... }:

with lib;

let cfg = config.satan.services.tailscale;
in {
  options.satan.services.tailscale = {
    enable = mkEnableOption "Enable the Tailscale connection";

    port = mkOption {
      type = types.int;
      default = 41641;
    };
  };

  config = mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      port = cfg.port;
    };

    networking.firewall = {
      allowedTCPPorts = [ cfg.port ];
      allowedUDPPorts = [ cfg.port ];
    };
  };
}
