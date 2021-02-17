{ config, pkgs, lib, ... }: {
  imports = [ ./hardware-configuration.nix ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd.luks.devices = {
      root = {
        device = "/dev/sda2";
        preLVM = true;
      };
    };
  };

  networking = {
    hostName = "barbossa";
    useDHCP = false;

    interfaces.eno1.useDHCP = true;
    interfaces.wlp0s20f3.useDHCP = true;

    firewall = { enable = true; };
  };

  fileSystems."/mnt/omnibus" = {
    device = "omnibus:/volume1/barbossa";
    fsType = "nfs";
    options = [
      "x-systemd.automount"
      "noauto"
    ]; # Don't mount until it's first accessed
  };

  satan.services = {
    nginx = {
      enable = true;
      contactEmail = "ethan.turkeltaub@hey.com";
    };

    plex = {
      enable = true;
      nginx = {
        enable = true;
        host = "plex.barbossa.dev";
      };
    };

    sonarr = {
      enable = true;
      nginx = {
        enable = true;
        host = "sonarr.barbossa.dev";
      };
    };

    radarr = {
      enable = true;
      nginx = {
        enable = true;
        host = "radarr.barbossa.dev";
      };
    };

    nzbget = {
      enable = true;
      nginx = {
        enable = true;
        host = "nzbget.barbossa.dev";
      };
    };

    builder = {
      enable = true;
      systems = [ "aarch64-linux" ];
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
