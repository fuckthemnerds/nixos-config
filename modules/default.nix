{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = let
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
    (getModules ./nixos) ++ (getModules ./home);
}
