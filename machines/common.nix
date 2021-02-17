{ lib, pkgs, ... }: {
  imports = [ ../modules/programs/index.nix ../modules/services/index.nix ];

  nix.gc = {
    automatic = true;
    dates = "03:15";
  };

  time.timeZone = "America/New_York";

  networking.firewall = { enable = true; };

  satan = {
    programs = { mosh.enable = true; };

    services = {
      openssh.enable = true;
      tailscale.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [ htop ];

}
