{ config, lib, pkgs, ... }:

with lib;

let cfg = config.satan.programs.fish;
in {
  options.satan.programs.fish = { enable = mkEnableOption "Enable Fish"; };

  config = mkIf cfg.enable {
    programs.fish.enable = true;
    users.users.root.shell = pkgs.fish;
  };
}
