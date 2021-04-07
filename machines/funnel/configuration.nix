{ config, pkgs, modulesPath, lib, ... }: {
  imports = [ (modulesPath + "/virtualisation/digital-ocean-config.nix") ];

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
