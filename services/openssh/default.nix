{ config, lib, pkgs, ... }:

with lib;

let cfg = config.satan.services.openssh;
in {
  options.satan.services.openssh = {
    enable = mkEnableOption "Enable OpenSSH";
  };

  config = mkIf cfg.enable {
    services.openssh.enable = true;

    networking.firewall = {
      allowedTCPPorts = [ 22 ];
      allowedUDPPorts = [ 22 ];
    };
  };
}
