{ pkgs, ... }: {
  nix.gc = {
    automatic = true;
    dates = "03:15";
  };

  time.timeZone = "America/New_York";

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [ 22 ];
    allowedUDPPortRanges = [{
      from = 60000;
      to = 61000;
    }];
  };

  services.openssh.enable = true;

  # services.zerotierone = {
  #   enable = true;
  #   joinNetworks = [ "e4da7455b2239e18" ];
  # };

  programs.mosh.enable = true;

  # deployment.healthChecks = {
  #   cmd = [{
  #     cmd = [ "systemctl" "is-active" "zerotierone.service" ];
  #     description = "Check if ZeroTier is running";
  #   }];
  # };

  environment.systemPackages = with pkgs; [ htop ];
}
