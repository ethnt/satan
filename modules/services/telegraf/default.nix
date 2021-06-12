{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.satan.services.telegraf;
  configFile = pkgs.writeText "config.toml" cfg.extraConfig;
in {
  options.satan.services.telegraf = {
    enable = mkEnableOption "Enable Telegraf";

    user = mkOption {
      type = types.str;
      default = "telegraf";
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
    };
  };

  config = mkIf cfg.enable {
    users.users.${cfg.user} = {
      createHome = false;
      extraGroups = [ "wheel" ];
      group = "users";
      isSystemUser = true;
    };

    # Open ports for SNMP
    networking.firewall = {
      allowedTCPPorts = [ 161 162 ];
      allowedUDPPorts = [ 161 162 ];
    };

    systemd.services.telegraf = {
      description = "Telegraf Agent";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      path = [ "/run/current-system/sw" ];
      serviceConfig = {
        ExecStart = ''${pkgs.telegraf}/bin/telegraf -config "${configFile}"'';
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        User = cfg.user;
        Restart = "on-failure";
      };
    };
  };
}
