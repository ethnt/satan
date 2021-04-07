{ config, lib, pkgs, ... }:

with lib;

let cfg = config.satan.services.fail2ban;
in {
  options.satan.services.fail2ban = {
    enable = mkEnableOption "Enable fail2ban";
  };

  config = mkIf cfg.enable {
    services.fail2ban = {
      enable = true;
      jails = {
        DEFAULT = ''
          bantime = 3600
          blocktype = DROP
          logpath = /var/log/auth.log
        '';

        ssh = ''
          enabled = true
          filter = sshd
          maxretry = 4
          action = iptables[name=SSH, port=ssh, protocol=tcp]
        '';
      };
    };
  };
}
