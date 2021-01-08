{ config, pkgs, modulesPath, lib, ... }: {
  imports = [
    (modulesPath + "/virtualisation/digital-ocean-config.nix")
    ../common.nix
    ./modules/pihole
    # ./modules/wireguard
  ];

  deployment = {
    targetUser = "root";
    targetHost = "funnel.satan.computer";
  };

  networking.hostName = "funnel";

  # nixpkgs.localSystem.system = "x86_64-linux";

  environment.systemPackages = with pkgs; [ dnsutils ];
}
