{ config, lib, pkgs, ... }:

with lib;

let cfg = config.satan.services.influxdb;
in {
  options.satan.services.influxdb = {
    enable = mkEnableOption "Enable InfluxDB";

    user = mkOption {
      type = types.str;
      default = "influxdb";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = {
      allowedTCPPorts = [ 8086 ];
      allowedUDPPorts = [ 8086 ];
    };

    services.influxdb = {
      enable = true;
      user = cfg.user;
    };
  };
}
