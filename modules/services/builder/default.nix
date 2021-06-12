{ config, lib, pkgs, ... }:

with lib;

let cfg = config.satan.services.builder;
in {
  options.satan.services.builder = {
    enable = mkEnableOption "Enable use as a remote builder";

    systems = mkOption {
      type = types.listOf types.string;
      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    boot.binfmt.emulatedSystems = cfg.systems;

    nix.trustedUsers = [ "builder" ];

    users.extraUsers.builder = {
      createHome = false;
      extraGroups = [ "wheel" ];
      group = "users";
      isSystemUser = true;
    };
  };
}
