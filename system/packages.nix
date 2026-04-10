{ pkgs, ... }:

{
	# ── SYSTEM-WIDE PACKAGES ──────────────────────────────────────────────────────
	environment.systemPackages = with pkgs; [
		# --- Nix Management ---
		nh                  # Next-gen Nix helper (clean CLI, auto GC)
		nvd                 # Visual diff between generations
		nix-output-monitor  # Progress bars for builds
		comma               # Instant app execution without installation
		alejandra           # Fast, opinionated Nix formatter

		# --- System Core & CLI ---
		git                 # Global git for system level tasks
		fzf                 # Fuzzy finder
		ripgrep             # Better grep
		eza                 # Modern ls replacement
		bat                 # Modern cat replacement
		fd                  # Better find
		tree                # Directory visualization
		zoxide              # Smarter cd
		yazi                # Blazing fast terminal file manager
		tldr                # Simplified community man pages

		# --- System Admin & Cloud ---
		ncdu                # Disk usage analyzer
		rclone              # Cloud mount/sync (OneDrive)
		fuse3               # Needed for rclone mounting
		sops                # Secret management CLI
		age                 # Modern encryption (sops backend)
		gnumake             # Essential build tool

		# --- Wayland & Desktop ---
		wl-clipboard        # Clipboard manager
		brightnessctl       # Backlight control
		playerctl           # Media control
		grim                # Screenshot capture
		slurp               # Screenshot area selector
		swappy              # Screenshot editor/annotation
		xdg-utils           # xdg-open & desktop integration
		adw-gtk3            # Libadwaita look for GTK3 apps

		# --- Hardware Monitoring ---
		nvtopPackages.full  # GPU monitoring (Aorus)
		powertop            # Battery monitoring (Surface)
		impala              # Bluetooth TUI
		pulsemixer          # Volume TUI

		# --- Applications ---
		librewolf           # Primary browser
		keepassxc           # Password manager
		imv                 # Image viewer
		mpv                 # Video player

		# --- Media & Utilities ---
		imagemagick         # Image processing
		ffmpeg              # Video/Audio processing
		curl                # Net downloads
		wget                # Net downloads
		unzip               # Archive support
		zip                 # Archive support
		p7zip               # Advanced archive support

		# --- AI Slop ---
		code-cursor         # AI-powered code editor
		claude-code         # Anthropic's agentic CLI
		antigravity         # High-performance agentic assistant
	];
}
