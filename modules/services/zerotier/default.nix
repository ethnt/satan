{ config, lib, pkgs, ... }:

with lib;

let cfg = config.satan.services.zerotier;
in {
  options.satan.services.zerotier = {
    enable = mkEnableOption "Enable the ZeroTier connection";

    networkIds = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    services.zerotierone = {
      enable = true;
      joinNetworks = cfg.networkIds;
    };
  };
}
