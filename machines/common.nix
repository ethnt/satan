{ lib, pkgs, ... }: {
  imports = [ ../programs/index.nix ../services/index.nix ];

  nix.gc = {
    automatic = true;
    dates = "03:15";
  };

  time.timeZone = "America/New_York";

  networking.firewall = {
    enable = true;
  };

  services.zerotierone = {
    enable = true;
    joinNetworks = [ "e4da7455b2239e18" ];
  };

  # programs.mosh.enable = true;

  satan = {
    programs = {
      mosh.enable = true;
    };

    services = {
      openssh.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [ htop ];

}
