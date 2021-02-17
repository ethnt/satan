build-funnel:
	nix build .#nixosConfigurations.funnel.config.system.build.toplevel

build-controller:
	nix build .#nixosConfigurations.controller.config.system.build.toplevel

build-barbossa:
	nix build .#nixosConfigurations.barbossa.config.system.build.toplevel --impure

deploy:
	nix develop -c "nix" "run" "github:serokell/deploy-rs" "--impure"
