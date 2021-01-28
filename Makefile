build-funnel:
	nix build .#nixosConfigurations.funnel.config.system.build.toplevel

deploy:
	nix-shell --command "NIX_SSHOPTS=\"-i ./keys/satan\" nix run github:serokell/deploy-rs"
