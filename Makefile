build:
	morph build network.nix

deploy:
	morph deploy network.nix switch

lint:
	nixfmt --check **/*.nix

format:
	nixfmt **/*.nix
