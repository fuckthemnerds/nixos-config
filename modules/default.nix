#############################################################
#
#  Registry - Dynamic Recursive Module Importer
#
#############################################################
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = let
    # Recursive helper to find all .nix modules in the subdirectories
    getModules = dir:
      lib.pipe dir [
        builtins.readDir
        (lib.mapAttrsToList (
          name: type: let
            path = dir + "/${name}";
          in
            if type == "directory"
            then getModules path
            else if type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix"
            then [path]
            else []
        ))
        lib.flatten
      ];
  in
    # Dynamically auto-import all NixOS modules defined under this directory
    getModules ./.;
}
