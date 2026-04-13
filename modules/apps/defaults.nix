{ config, lib, pkgs, ... }:
let
	dirContents = builtins.readDir ./.;
	appFiles = lib.filterAttrs (name: type:
		type == "regular" &&
		lib.hasSuffix ".nix" name &&
		name != "defaults.nix" &&
		!lib.hasPrefix "_" name
	) dirContents;
	appNames = map (name: lib.removeSuffix ".nix" name) (builtins.attrNames appFiles);
in
{
	apps = lib.genAttrs appNames (name: {
		enable = lib.mkDefault true;
	});

	xdg = {
		mimeApps = {
			enable = true;
			defaultApplications = {
				"text/plain"                  = "nvim.desktop";
				"text/x-shellscript"          = "nvim.desktop";
				"application/pdf"             = "org.pwmt.zathura.desktop";

				"text/html"                   = "librewolf.desktop";
				"x-scheme-handler/http"       = "librewolf.desktop";
				"x-scheme-handler/https"      = "librewolf.desktop";
				"x-scheme-handler/about"      = "librewolf.desktop";
				"x-scheme-handler/unknown"    = "librewolf.desktop";

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
}