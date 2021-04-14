deploy:
	nixops deploy -d satan

info:
	nixops info -d satan

setup:
	nixops create -d satan --flake "."
