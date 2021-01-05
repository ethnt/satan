{ config, pkgs, lib, ... }: {
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  nixpkgs.localSystem.system = "aarch64-linux";

  boot.kernelPackages = pkgs.linuxPackages;

  boot.kernelParams = [ "cma=64M" ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";

  users.users.nixos = {
    createHome = true;
    extraGroups = [ "wheel" ];
    group = "users";
    isNormalUser = true;
    uid = 1000;
  };

  swapDevices = [ { device = "/swapfile"; size = 1024; } ];
}
