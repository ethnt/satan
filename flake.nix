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
      #   - platform: See a `platform` from above
      #   - machine: The name of the machine
      #   - machineConfiguration: Path to the configuration (optional, defaults to ./machines/${machine}/configuration.nix)
      #   - extraModules: Extra modules to include (optional, defaults to empty list)
      mkConfig = { platform, machine
        , machineConfiguration ? ./machines + "/${machine}/configuration.nix"
        , extraModules ? [ ] }:
        let
          # This is an attribute set common between all machines (basically a top-level NixOS configuration)
          defaults = { pkgs, lib, ... }: {
            imports = [ ./machines/common.nix machineConfiguration ]
              ++ extraModules;
          };
          # This gets boiled down to a nixosSystem
        in inputs.nixpkgs.lib.nixosSystem {
          system = platform;
          pkgs = nixpkgsFor.${platform};
          specialArgs = { inherit inputs nixpkgs; };
          modules = [ defaults ];
        };

      # TODO: Combine this and mkConfig into one function?
      mkNode = { hostname, machine, platform }: {
        hostname = hostname;
        profiles.system = {
          sshUser = "root";
          sshOpts = [ "-i" "./keys/satan" ];
          path = deploy-rs.lib.${platform}.activate.nixos
            self.nixosConfigurations.${machine};
        };
      };
    in {
      nixosConfigurations = {
        funnel = mkConfig {
          platform = "x86_64-linux";
          machine = "funnel";
        };

        controller = mkConfig {
          platform = "aarch64-linux";
          machine = "controller";
        };
      };

      deploy.nodes = {
        funnel = mkNode {
          platform = "x86_64-linux";
          hostname = "161.35.142.17";
          machine = "funnel";
        };

        controller = mkNode {
          platform = "aarch64-linux";
          hostname = "192.168.1.57";
          machine = "controller";
        };
      };

      checks = builtins.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    } // (flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in { devShell = import ./shell.nix { inherit pkgs; }; }));
}
