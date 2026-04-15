{ config, lib, pkgs, globals, ... }:
let
	dirContents = builtins.readDir ./.;
	appFiles = lib.filterAttrs (name: type:
		(type == "regular" && lib.hasSuffix ".nix" name && name != "defaults.nix" && !lib.hasPrefix "_" name) ||
		(type == "directory" && builtins.pathExists (./. + "/${name}/default.nix"))
	) dirContents;
	appNames = map (name: if dirContents.${name} == "directory" then name else lib.removeSuffix ".nix" name) (builtins.attrNames appFiles);
in
{
	apps = lib.genAttrs appNames (name: {
		enable = lib.mkDefault true;
	});

	home-manager.users.${globals.userName} = {
		xdg = {
			mimeApps = {
				enable = true;
				defaultApplications = {
					"text/plain"                  = "nvim.desktop";
					"text/x-shellscript"          = "nvim.desktop";
					"application/pdf"             = "org.pwmt.zathura.desktop";

					"text/html"                   = "zen.desktop";
					"x-scheme-handler/http"       = "zen.desktop";
					"x-scheme-handler/https"      = "zen.desktop";
					"x-scheme-handler/about"      = "zen.desktop";
					"x-scheme-handler/unknown"    = "zen.desktop";

					"image/png"                   = "imv.desktop";
					"image/jpeg"                  = "imv.desktop";
					"image/gif"                   = "imv.desktop";
					"image/webp"                  = "imv.desktop";
					"image/svg+xml"               = "imv.desktop";
					"video/mp4"                   = "mpv.desktop";
					"video/webm"                  = "mpv.desktop";
					"video/mkv"                   = "mpv.desktop";

					"application/zip"             = "org.gnome.FileRoller.desktop";
					"application/x-tar"           = "org.gnome.FileRoller.desktop";
				};
			};

			userDirs = {
				enable              = true;
				setSessionVariables = true;
				createDirectories   = true;
				download    = "$HOME/Downloads";
				documents   = "$HOME/Documents";
				music       = "$HOME/Music";
				pictures    = "$HOME/Pictures";
				videos      = "$HOME/Videos";
				desktop     = "$HOME";
				publicShare = "$HOME";
				templates   = "$HOME";
			};
		};

		home.sessionVariables = {
			EDITOR   = "nvim";
			VISUAL   = "nvim";
			MANPAGER = "nvim +Man!";
			PAGER    = "bat --style=plain";
			SSH_AUTH_SOCK = "\${XDG_RUNTIME_DIR}/app/org.keepassxc.KeePassXC/ssh-agent.socket";
		};
	};
}