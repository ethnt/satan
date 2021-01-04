{ pkgs, ... }: {
  nix.gc = {
    automatic = true;
    dates = "03:15";
  };

  services.openssh.enable = true;

  services.zerotierone = {
    enable = true;
    joinNetworks = [ "e4da7455b2239e18" ];
  };

  programs.mosh.enable = true;

  environment.systemPackages = with pkgs; [ htop ];
}
