{ config, pkgs, lib, ... }: {
  imports = [ ./hardware-configuration.nix ];

  satan = {
    services = {
      unifi.enable = false;
    };
  };

  networking.hostName = "controller";
}
