{ config, pkgs, modulesPath, lib, ... }: {
  imports = [
    (modulesPath + "/virtualisation/digital-ocean-config.nix")
    ./modules/pihole
  ];

  networking.hostName = "funnel";

  environment.systemPackages = with pkgs; [ dnsutils ];
}
