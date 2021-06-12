{
  description = "Satan";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-20.09-small";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable-small";
    flake-utils.url = "github:numtide/flake-utils";
    sops-nix.url = "github:Mic92/sops-nix";
    nixops.url = "github:nixos/nixops";
  };

  outputs =
    inputs@{ self, nixpkgs, nixpkgs-unstable, flake-utils, sops-nix, nixops }:
    let
      inherit (nixpkgs) lib;

      # List of all used platforms/architectures
      platforms = [ "x86_64-linux" "aarch64-linux" ];

      # Helper to do a thing for all our platforms
      forAllPlatforms = f: lib.genAttrs platforms (platform: f platform);

      # Generates a nixpkgs configuration for all of our platforms
      nixpkgsFor = let
        overlay-unstable = final: prev: {
          unstable = nixpkgs-unstable.legacyPackages.x86_64-linux;
        };
      in forAllPlatforms (platform:
        import nixpkgs {
          system = platform;
          overlays = [ overlay-unstable ];
          config.allowUnfree = true;
        });

      # Make a deployment.
      mkDeployment = { host, platform, machineName, machineConfiguration ?
          ./machines + "/${machineName}/configuration.nix", secrets ? { } }: {
            deployment = {
              targetHost = host;
              keys = secrets;
            };

            nixpkgs.pkgs = nixpkgsFor.${platform};
            nixpkgs.localSystem.system = platform;

            imports = [
              # nixpkgs.nixosModules.notDetected
              ./machines/common.nix
              machineConfiguration
            ];
          };

      region = "us-east-2";
    in {
      nixopsConfigurations.default = {
        inherit nixpkgs;

        network = {
          description = "satan";
          enableRollback = true;
        };

        funnel = mkDeployment {
          host = "161.35.142.17";
          platform = "x86_64-linux";
          machineName = "funnel";
        };

        barbossa = mkDeployment {
          host = "barbossa.dev";
          platform = "x86_64-linux";
          machineName = "barbossa";
          secrets = {
            wireguard-wg0 = {
              keyFile = ./machines/barbossa/secrets/wireguard/wg0.conf;
            };

            users-ethan-password = {
              keyFile = ./machines/barbossa/secrets/users/ethan/password;
            };
          };
        };

        resources = import ./resources { inherit region; };
      };
    } // (flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs-unstable.legacyPackages.${system};
      in {
        devShell = import ./shell.nix {
          inherit pkgs;
          inherit sops-nix;
        };
      }));
}
