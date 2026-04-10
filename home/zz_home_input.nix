{ lib, ... }:

let
	localLib = import ../lib.nix { inherit lib; };
in
{
	# Aggregate all home-manager categories
	imports = 
		(localLib.importModules ./apps) ++
		(localLib.importModules ./core) ++
		(localLib.importModules ./themes);
}
