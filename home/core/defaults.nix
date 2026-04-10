{ pkgs, ... }:

{
	xdg.mimeApps = {
		enable = true;
		defaultApplications = {
			# Text & Documents
			"text/plain"                  = "nvim.desktop";
			"text/x-shellscript"          = "nvim.desktop";
			"application/pdf"             = "org.pwmt.zathura.desktop";

			# Web
			"text/html"                   = "librewolf.desktop";
			"x-scheme-handler/http"       = "librewolf.desktop";
			"x-scheme-handler/https"      = "librewolf.desktop";
			"x-scheme-handler/about"      = "librewolf.desktop";
			"x-scheme-handler/unknown"    = "librewolf.desktop";

			# Media
			"image/png"                   = "imv.desktop";
			"image/jpeg"                  = "imv.desktop";
			"image/gif"                   = "imv.desktop";
			"image/webp"                  = "imv.desktop";
			"image/svg+xml"               = "imv.desktop";
			"video/mp4"                   = "mpv.desktop";
			"video/webm"                  = "mpv.desktop";
			"video/mkv"                   = "mpv.desktop";

			# Archives
			"application/zip"             = "org.gnome.FileRoller.desktop";
			"application/x-tar"           = "org.gnome.FileRoller.desktop";
		};
	};

	home.sessionVariables = {
		EDITOR   = "nvim";
		VISUAL   = "nvim";
		MANPAGER = "nvim +Man!";
		PAGER    = "bat --style=plain";
		SSH_AUTH_SOCK = "\${XDG_RUNTIME_DIR}/app/org.keepassxc.KeePassXC/ssh-agent.socket";
	};

	xdg.userDirs = {
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
}
