{ config, lib, pkgs, ... }:

with lib;

let cfg = config.satan.services.nginx;
in {
  options.satan.services.nginx = {
    enable = mkEnableOption "Enable Nginx";
    contactEmail = mkOption { type = types.str; };
    virtualHosts = mkOption {
      type = types.attrs;
      default = { };
    };
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;

      package = pkgs.nginx.override {
        fullWebDAV = true;
        modules = [
          pkgs.nginxModules.pam
          pkgs.nginxModules.dav
          pkgs.nginxModules.moreheaders
          pkgs.nginxModules.fancyindex
        ];
      };

      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts = cfg.virtualHosts;
    };

    security.acme.acceptTerms = true;
    security.acme.email = cfg.contactEmail;

    networking.firewall = {
      allowedTCPPorts = [ 80 443 ];
      allowedUDPPorts = [ 80 443 ];
    };
  };
}
