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

  users.users.ethan = {
    createHome = true;
    extraGroups = [ "wheel" ];
    group = "users";
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

    sabre = {
      enable = true;
      path = "/mnt/omnibus/data/sync";
      nginx = {
        enable = true;
        host = "sync.barbossa.dev";
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

    transmission = {
      enable = true;
      settingsPath = ./etc/transmission/settings.json;
      nginx = {
        enable = true;
        host = "transmission.barbossa.dev";
      };
    };

    wireguard = {
      enable = false;
      externalInterface = "eno1";
      ip = "10.100.0.2/24";
      privateKeyFile = config.deployment.keys.wg-private-key.path;
      peers = [ {
        publicKey = "K3yHsof9OU8+FjwnRfgZ7Aw8Wp1LR9L/fsaoQI9JCTE=";
        allowedIPs = [ "10.100.0.1/24" ];
        endpoint = "161.35.142.17:51820";
        persistentKeepalive = 25;
      }];
    };

    wireguard-container = { enable = true; };

    xteve = {
      enable = true;
      envFile = ./etc/xteve/env;
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
