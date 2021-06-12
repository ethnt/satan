deploy:
	nixops deploy -d satan -k

info:
	nixops info -d satan

setup:
	nixops create -d satan --flake "."
