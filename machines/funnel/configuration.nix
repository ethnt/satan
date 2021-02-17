{ config, pkgs, modulesPath, lib, ... }: {
  imports = [ (modulesPath + "/virtualisation/digital-ocean-config.nix") ];

  networking.hostName = "funnel";

  environment.systemPackages = with pkgs; [ dnsutils ];

  # satan = { services = { pihole.enable = true; }; };
}
