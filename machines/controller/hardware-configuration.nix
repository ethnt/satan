{ config, pkgs, lib, ... }: {
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  # nixpkgs.localSystem.system = "aarch64-linux";

  boot.kernelPackages = pkgs.linuxPackages;

  boot.kernelParams = [ "cma=64M" ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  swapDevices = [{
    device = "/swapfile";
    size = 1024;
  }];
}
