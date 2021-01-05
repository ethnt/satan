{ config, pkgs, modulesPath, lib, ... }: {
  imports = [
    (modulesPath + "/virtualisation/digital-ocean-config.nix")
    ../common.nix
    ./modules/unbound
    ./modules/pihole
  ];

  deployment = {
    targetUser = "root";
    targetHost = "64.225.14.103";
  };

  networking.hostName = "funnel";

  nixpkgs.localSystem.system = "x86_64-linux";

  environment.systemPackages = with pkgs; [ dnsutils ];
}
