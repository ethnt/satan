{ config, lib, pkgs, ... }:

with lib;

let cfg = config.satan.services.podman;
in {
  options.satan.services.podman = { enable = mkEnableOption "Enable Podman"; };

  config = mkIf cfg.enable {
    virtualisation = {
      podman = {
        enable = true;
        dockerCompat = true;
      };

      oci-containers.backend = "podman";
    };
  };
}
