{ config, pkgs, lib, ... }: {
  imports = [ ./hardware-configuration.nix ../common.nix ./modules/unifi ];

  deployment = {
    targetUser = "root";
    targetHost = "192.168.1.57";
  };

  networking.hostName = "controller";
}
