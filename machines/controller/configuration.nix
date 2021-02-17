{ config, pkgs, lib, ... }: {
  imports = [ ./hardware-configuration.nix ];

  satan = {
    services = {
      unifi.enable = true;
    };
  };

  networking.hostName = "controller";
}
