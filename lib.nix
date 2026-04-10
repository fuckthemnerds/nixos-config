{ lib, ... }:

{
	# Recursive module importer
	# Scans a directory and returns a list of all .nix files (excluding default.nix and files starting with _)
	scanPaths = path:
		builtins.map (f: (path + "/${f}")) (
			builtins.attrNames (
				lib.filterAttrs (
					pathName: type:
						let
							dirName = baseNameOf path;
						in
						(type == "regular" && lib.hasSuffix ".nix" pathName && 
						 pathName != "default.nix" && 
						 pathName != "${dirName}.nix" && 
						 pathName != "zz_${dirName}_input.nix" && 
						 !lib.hasPrefix "_" pathName)
						|| (type == "directory")
				) (builtins.readDir path)
			)
		);

	# A more advanced importer that recursively finds all modules
	# Similar to haumea or import-tree but simpler
	importModules = dir:
		let
			contents = builtins.readDir dir;
			files = lib.filterAttrs (n: v: v == "regular" && lib.hasSuffix ".nix" n && n != "default.nix" && !lib.hasPrefix "_" n) contents;
			dirs = lib.filterAttrs (n: v: v == "directory") contents;
			
			fileNames = builtins.attrNames files;
			filePaths = map (n: dir + "/${n}") fileNames;
			dirPaths = map (n: dir + "/${n}") (builtins.attrNames dirs);
			
			# Entry points for directories (in order of preference)
			processDir = d:
				let
					dirName = baseNameOf d;
					zzInput = d + "/zz_${dirName}_input.nix";
					namedNix = d + "/${dirName}.nix";
					defaultNix = d + "/default.nix";
				in
				if builtins.pathExists zzInput then [ zzInput ]
				else if builtins.pathExists namedNix then [ namedNix ]
				else if builtins.pathExists defaultNix then [ defaultNix ]
				else importModules d;
		in
		filePaths ++ (lib.concatMap processDir dirPaths);
}
