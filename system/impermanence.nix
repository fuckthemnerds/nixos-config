{ config, lib, userName, ... }:

{
	# ── ROOT ROLLBACK SCRIPT ──────────────────────────────────────────────────────
	# Automatically wipes the root subvolume and restores it to a clean state
	# on every boot. Old roots are archived and purged after 30 days.
	boot.initrd.systemd.services.rollback = {
		description = "Rollback Btrfs root";
		wantedBy = [ "initrd.target" ];
		after = [ "initrd-root-device.target" ];
		before = [ "sysroot.mount" ];
		unitConfig.DefaultDependencies = "no";
		serviceConfig.Type = "oneshot";
		script = ''
		echo "--- BTRFS ROLLBACK: Cleaning Root Subvolume ---"
		mkdir -p /btrfs_tmp
		mount -o subvol=/ /dev/disk/by-label/nixos /btrfs_tmp

		if [[ -e /btrfs_tmp/root ]]; then
		mkdir -p /btrfs_tmp/old_roots
		timestamp=$(date "+%Y-%m-%d_%H:%M:%S")
		echo "Archiving current root to /old_roots/$timestamp..."
		mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
		fi

		delete_subvolume_recursively() {
			IFS=$'\n'
			for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
			delete_subvolume_recursively "/btrfs_tmp/$i"
			done
			btrfs subvolume delete "$1"
		}

		if [[ -d /btrfs_tmp/old_roots ]]; then
		find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30 | while read root; do
		if [[ "$root" != "/btrfs_tmp/old_roots/" ]]; then
		echo "Deleting expired root: $root"
		delete_subvolume_recursively "$root"
		fi
		done
		fi

		echo "Restoring blank root subvolume..."
		btrfs subvolume snapshot /btrfs_tmp/blank /btrfs_tmp/root

		umount /btrfs_tmp
		'';
	};

	# ── PERSISTENCE CONFIGURATION ─────────────────────────────────────────────────

	# Ensure /persistent is mounted early for secrets (SOPS-Nix)
	fileSystems."/persistent".neededForBoot = true;

	environment.persistence."/persistent" = {
		hideMounts = true;

		# --- System Mappings ---
		directories = [
			"/var/log"
			"/var/lib/bluetooth"
			"/var/lib/nixos"
			"/var/lib/systemd/coredump"
			"/etc/NetworkManager/system-connections"
			"/var/lib/NetworkManager"
		];
		files = [
			"/etc/machine-id"
		];

		# --- User Mappings ---
		users.${userName} = {
			directories = [
				"Downloads"
				"Music"
				"Pictures"
				"Documents"
				"Videos"
				".ssh"
				".local/share/keyrings"
				".local/share/fish"    # Persistent shell history
				".local/share/nvim"    # Persistent editor data
				".local/state/nvim"    # Persistent editor state (undo)
				".librewolf"
				".config/niri"
				".config/wayland-sessions"
				".local/share/zoxide"  # Persistent zoxide history
				".local/share/direnv"  # Persistent direnv permissions
				".local/share/yazi"    # Persistent file manager state
				".config/rclone"       # Persistent cloud storage configs
				".config/keepassxc"    # Persistent password manager settings
				".config/Code - Cursor" # Persistent IDE state & extensions
				".local/state/wireplumber" # Persistent audio routing memory
				".cache/bat"           # Persistent bat theme/syntax cache
			];
		};
	};
}
