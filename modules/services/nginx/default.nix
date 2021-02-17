{ config, lib, pkgs, ... }:

with lib;

let cfg = config.satan.services.nginx;
in {
  options.satan.services.nginx = {
    enable = mkEnableOption "Enable Nginx";
    contactEmail = mkOption { type = types.str; };
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
    };

    security.acme.acceptTerms = true;
    security.acme.email = cfg.contactEmail;

    networking.firewall = {
      allowedTCPPorts = [ 80 443 ];
      allowedUDPPorts = [ 80 443 ];
    };
  };
}
