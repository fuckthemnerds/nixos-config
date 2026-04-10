{ lib, ... }:

let
	localLib = import ../lib.nix { inherit lib; };
in
{
	imports = localLib.importModules ./.;
}
