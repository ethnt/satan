build-funnel:
	nix build .#nixosConfigurations.funnel.config.system.build.toplevel

build-controller:
	nix build .#nixosConfigurations.controller.config.system.build.toplevel

deploy:
	nix develop -c "nix" "run" "github:serokell/deploy-rs"
