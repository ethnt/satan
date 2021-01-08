build:
	morph build network.nix

deploy:
	morph deploy network.nix switch

upload-secrets:
	morph upload-secrets network.nix

lint:
	nixfmt --check **/*.nix

format:
	nixfmt **/*.nix
