{ config, lib, pkgs, ... }:

with lib;

let cfg = config.satan.programs.mosh;
in {
  options.satan.programs.mosh = { enable = mkEnableOption "Enable mosh"; };

  config = mkIf cfg.enable {
    programs.mosh.enable = true;

    networking.firewall.allowedUDPPortRanges = [{
      from = 60000;
      to = 61000;
    }];
  };
}
