{ config, pkgs, lib, ... }: {
  imports = [ ./hardware-configuration.nix ./modules/unifi ];

  # deployment = {
  #   targetUser = "root";
  #   targetHost = "192.168.1.57";
  # };

  networking.hostName = "controller";
}
