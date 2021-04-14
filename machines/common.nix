{ config, lib, pkgs, ... }: {
  imports = [ ../modules/programs/index.nix ../modules/services/index.nix ];

  nix = {
    gc = {
      automatic = true;
      dates = "03:15";
    };

    extraOptions = ''
      plugin-files = ${
        pkgs.nix-plugins.override { nix = config.nix.package; }
      }/lib/nix/plugins/libnix-extra-builtins.so
    '';
  };

  time.timeZone = "America/New_York";

  networking.firewall = { enable = true; };

  users = {
    groups = { keys = {}; };
    users = {
      keys = {
        createHome = false;
        group = "keys";
      };
    };
  };

  satan = {
    programs = {
      fish.enable = true;
      mosh.enable = true;
    };

    services = {
      openssh.enable = true;
      zerotier.enable = true;
      rsyslogd = {
        enable = true;
        syslogServer = "10.241.9.173:5144";
      };
      fail2ban = { enable = true; };
    };
  };

  environment.systemPackages = with pkgs; [ htop ];
}
