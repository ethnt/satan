{ config, pkgs, lib, ... }: {
  imports = [ ./hardware-configuration.nix ];

  sops.defaultSopsFile = ../../secrets.yaml;

  sops.secrets.services_sabre_username = { };
  sops.secrets.services_sabre_password = { };

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

    builder = {
      enable = true;
      systems = [ "aarch64-linux" ];
    };

    fail2ban = { enable = true; };

    jackett = {
      enable = true;
      nginx.enable = true;
      nginx.host = "jackett.barbossa.dev";
    };

    transmission = {
      enable = true;
      nginx = {
        enable = true;
        host = "transmission.barbossa.dev";
      };
    };

    wireguard = {
      enable = true;
      address = {
        ipv4 = "10.72.166.76/32";
        ipv6 = "fc00:bbbb:bbbb:bb01::9:a64b/128";
      };
      peer = "+/HYwELAaww6XTtPmvf3Hr8NqLIr69YNUpAMBvWJiGw=";
      endpoint = "86.106.143.15:3214";
      privateKey = "w4J3Pdi1ZJdBfJH6g/506G3a1FekkjZyDlICL72iBqU=";
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
