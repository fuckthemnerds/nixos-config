{ config, lib, pkgs, globals, ... }:

{
	apps = {
		ai.enable = lib.mkDefault true;
		btop.enable = lib.mkDefault true;
		cliphist.enable = lib.mkDefault true;
		fastfetch.enable = lib.mkDefault true;
		fish.enable = lib.mkDefault true;
		foot.enable = lib.mkDefault true;
		fuzzel.enable = lib.mkDefault true;
		git.enable = lib.mkDefault true;
		gui-apps.enable = lib.mkDefault true;
		hypridle.enable = lib.mkDefault true;
		hyprlock.enable = lib.mkDefault true;
		keepassxc.enable = lib.mkDefault true;
		localsend.enable = lib.mkDefault true;
		mako.enable = lib.mkDefault true;
		modern-cli.enable = lib.mkDefault true;
		multimedia.enable = lib.mkDefault true;
		niri.enable = lib.mkDefault true;
		nvim.enable = lib.mkDefault true;
		rclone.enable = lib.mkDefault true;
		waybar.enable = lib.mkDefault true;
		yazi.enable = lib.mkDefault true;
		zathura.enable = lib.mkDefault true;
		zen.enable = lib.mkDefault true;
		zoxide.enable = lib.mkDefault true;
	};

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
