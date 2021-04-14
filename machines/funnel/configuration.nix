{ config, pkgs, modulesPath, lib, deployment, ... }: {
  imports = [ (modulesPath + "/virtualisation/digital-ocean-config.nix") ];

  deployment.hasFastConnection = true;

  networking.hostName = "funnel";

  environment.systemPackages = with pkgs; [ dnsutils ];

  satan = {
    services = {
      telegraf = {
        enable = true;
        extraConfig = (builtins.readFile ./etc/telegraf/inputs.toml)
          + (builtins.readFile ./etc/telegraf/outputs.toml);
      };

      wireguard = {
        enable = false;
        externalInterface = "ens3";
        ip = "10.100.0.1/24";
        privateKeyFile = config.deployment.keys.wg-private-key.path;
        peers = [ {
          publicKey = "UyI+7xqpk7C5NBSveuYCBADBq0DHJKlPJ/tHudgjW1g=";
          allowedIPs = [ "10.100.0.2/32" ];
        }];
      };
    };
  };
}
