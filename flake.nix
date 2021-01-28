{
  description = "Satan";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, deploy-rs }:
    {
      nixosConfigurations = {
        funnel = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs nixpkgs; };
          modules = [ ./machines/funnel/configuration.nix ];
        };
      };

      deploy.nodes.funnel = {
        hostname = "161.35.142.17";
        profiles.system = {
          sshUser = "root";
          sshOpts = [ "-i" "./keys/satan" ];
          path = deploy-rs.lib.x86_64-linux.activate.nixos
            self.nixosConfigurations.funnel;
        };
      };

      checks = builtins.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    } // (flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in { devShell = import ./shell.nix { inherit pkgs; }; }));
}
