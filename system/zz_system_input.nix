{ lib, ... }:

let
	localLib = import ../lib.nix { inherit lib; };
in
{
	# Automatically import everything in the system directory
	imports = localLib.scanPaths ./.;
}
