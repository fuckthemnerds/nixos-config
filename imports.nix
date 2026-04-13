{ lib, ... }:
let
  findModules = dir:
    let
      contents = builtins.readDir dir;
      processEntry = name: type:
        let
          path = dir + "/${name}";
        in
        if type == "directory" then
          if builtins.pathExists (path + "/default.nix")
          then [ (path + "/default.nix") ]
          else findModules path
        else if type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix"
        then [ path ]
        else [ ];
    in
    lib.concatLists (lib.mapAttrsToList processEntry contents);
in
{
  importModules = findModules;
}