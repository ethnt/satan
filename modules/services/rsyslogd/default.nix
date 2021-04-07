{ config, lib, pkgs, ... }:

with lib;

let cfg = config.satan.services.rsyslogd;
in {
  options.satan.services.rsyslogd = {
    enable = mkEnableOption "Enable rsyslogd";
    syslogServer = mkOption { type = types.str; };
  };

  config = mkIf cfg.enable {
    services.rsyslogd = {
      enable = true;
      # extraConfig = ''
      #   *.* @10.241.9.173:5144;RSYSLOG_SyslogProtocol23Format
      # '';
      extraConfig = ''
        *.* @${cfg.syslogServer};RSYSLOG_SyslogProtocol23Format
      '';
    };
  };
}
