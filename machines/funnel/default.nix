{ config, pkgs, modulesPath, lib, ... }: {
  imports = [ (modulesPath + "/virtualisation/digital-ocean-config.nix") ];

  deployment = {
    targetUser = "root";
    targetHost = "64.225.14.103";
  };

  networking.hostName = "funnel";

  nixpkgs.localSystem.system = "x86_64-linux";

  nix.gc = {
    automatic = true;
    dates = "03:15";
  };

  environment.systemPackages = with pkgs; [ bat openvpn ];

  programs.mosh.enable = true;
}
