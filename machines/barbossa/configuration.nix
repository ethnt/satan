{ config, pkgs, lib, ... }: {
  imports = [ ./hardware-configuration.nix ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd.luks = {
      devices = {
        root = {
          device = "/dev/sda2";
          preLVM = true;
        };
      };
    };
  };

  nix.maxJobs = lib.mkDefault 8;

  networking = {
    hostName = "barbossa";
    useDHCP = false;

    interfaces.eno1.useDHCP = true;
    interfaces.wlp0s20f3.useDHCP = true;
  };

  fileSystems."/mnt/omnibus" = {
    device = "omnibus:/volume1/barbossa";
    fsType = "nfs";
    options = [
      "x-systemd.automount"
      "noauto"
    ]; # Don't mount until it's first accessed
  };

  users = {
    groups = {
      users = {
        name = "users";
        gid = 100;
      };
    };

    users = {
      barbossa = {
        name = "barbossa";
        createHome = false;
        extraGroups = [ "wheel" ];
        group = "users";
        uid = 1005;
        isSystemUser = true;
      };

      ethan = {
        group = "users";
        extraGroups = [ "wheel" ];
        passwordFile = config.deployment.keys.users-ethan-password.path;
        createHome = true;
        home = "/home/ethan";
        shell = pkgs.fish;
        isNormalUser = true;
      };
    };
  };

  satan.services = {
    builder = {
      enable = true;
      systems = [ "aarch64-linux" ];
    };

    nginx = {
      enable = true;
      contactEmail = "ethan.turkeltaub@hey.com";
      virtualHosts = {
        "e10.land" = {
          addSSL = true;
          enableACME = true;

          locations."/" = {
            root = "/var/www/e10.land";
            extraConfig = ''
              autoindex on;
              fancyindex on;
            '';
          };
        };
      };
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
      uid = config.users.users.barbossa.uid;
      gid = config.users.groups.users.gid;
      extraVolumes = [ "/mnt:/mnt" ];
      nginx = {
        enable = true;
        host = "sonarr.barbossa.dev";
      };
    };

    radarr = {
      enable = true;
      uid = config.users.users.barbossa.uid;
      gid = config.users.groups.users.gid;
      extraVolumes = [ "/mnt:/mnt" ];
      nginx = {
        enable = true;
        host = "radarr.barbossa.dev";
      };
    };

    nzbget = {
      enable = true;
      user = "barbossa";
      group = "users";
      nginx = {
        enable = true;
        host = "nzbget.barbossa.dev";
      };
    };

    graylog = {
      enable = true;
      nginx = {
        enable = true;
        host = "graylog.barbossa.dev";
      };
    };

    grafana = {
      enable = true;
      nginx = {
        enable = true;
        host = "grafana.barbossa.dev";
      };
    };

    influxdb = { enable = true; };

    telegraf = {
      enable = true;
      extraConfig = (builtins.readFile ./etc/telegraf/inputs.toml)
        + (builtins.readFile ./etc/telegraf/outputs.toml);
    };

    overseerr = {
      enable = true;
      nginx.enable = true;
      nginx.host = "overseerr.barbossa.dev";
    };

    podman = { enable = true; };

    jackett = {
      enable = true;
      nginx.enable = true;
      nginx.host = "jackett.barbossa.dev";
    };

    wireguard-container = { enable = true; };

    xteve = {
      enable = true;
      envFile = ./etc/xteve/env;
    };

    qbittorrent = {
      enable = true;
      uid = config.users.users.barbossa.uid;
      gid = config.users.groups.users.gid;
      downloadsDir = "/mnt/omnibus/qbittorrent/downloads";
      extraVolumes = [ "/mnt:/mnt" ];
      wireguard = { enable = true; };
      nginx = {
        enable = true;
        host = "qbittorrent.barbossa.dev";
      };
    };

    bazarr = {
      enable = true;
      nginx = {
        enable = true;
        host = "bazarr.barbossa.dev";
      };
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
