{
  nix.gc = {
    automatic = true;
    dates = "03:15";
  };

  programs.mosh.enable = true;

  services.zerotierone = {
    enable = true;
    joinNetworks = [ "e4da7455b2239e18" ];
  };
}
