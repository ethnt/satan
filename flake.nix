{
  description = "Satan";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, deploy-rs }:
    let
      inherit (nixpkgs) lib;

      # List of all used platforms/architectures
      platforms = [ "x86_64-linux" "aarch64-linux" ];

      # Helper to do a thing for all our platforms
      forAllPlatforms = f: lib.genAttrs platforms (platform: f platform);

      # Generates a nixpkgs configuration for all of our platforms
      nixpkgsFor = forAllPlatforms (platform:
        import nixpkgs {
          system = platform;
          config.allowUnfree = true;
        });

      # A function to generate a standard configuration. Arguments are:
      #   - system: See a `platform` from above
      #   - machine: The name of the machine
      #   - machineConfiguration: Path to the configuration (optional, defaults to ./machines/${machine}/configuration.nix)
      #   - extraModules: Extra modules to include (optional, defaults to empty list)
      mkConfig = { system, machine
        , machineConfiguration ? ./machines + "/${machine}/configuration.nix"
        , extraModules ? [ ] }:
        let
          defaults = { pkgs, lib, ... }: {
            imports = [ machineConfiguration ];

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

            services.zerotierone = {
              enable = true;
              joinNetworks = [ "e4da7455b2239e18" ];
            };

            programs.mosh.enable = true;

            environment.systemPackages = with pkgs; [ htop ];
          };
        in inputs.nixpkgs.lib.nixosSystem {
          modules = [ defaults ] ++ extraModules;
          system = system;
          specialArgs = { inherit inputs nixpkgs; };
          pkgs = nixpkgsFor.${system};
        };
    in {
      nixosConfigurations = {
        funnel = mkConfig {
          system = "x86_64-linux";
          machine = "funnel";
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
