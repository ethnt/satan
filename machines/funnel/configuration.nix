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
    };
  };
}
