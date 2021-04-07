{ lib, pkgs, ... }: {
  imports = [ ../modules/programs/index.nix ../modules/services/index.nix ];

  nix.gc = {
    automatic = true;
    dates = "03:15";
  };

  time.timeZone = "America/New_York";

  networking.firewall = { enable = true; };

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
    };
  };

  environment.systemPackages = with pkgs; [ htop ];
}
