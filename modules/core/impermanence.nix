{ config, pkgs, lib, userName, ... }:

{
	boot.initrd.systemd.services.rollback = {
		description = "Rollback Btrfs root";
		wantedBy = [ "initrd.target" ];
		after = [ "initrd-root-device.target" "dev-disk-by\\x2dlabel-nixos.device" ];
		requires = [ "dev-disk-by\\x2dlabel-nixos.device" ];
		before = [ "sysroot.mount" ];
		unitConfig.DefaultDependencies = "no";
		serviceConfig.Type = "oneshot";
		path = [ pkgs.btrfs-progs ];
		script = ''
		mkdir -p /btrfs_tmp
		mount -o subvol=/ /dev/disk/by-label/nixos /btrfs_tmp

		if [[ -e /btrfs_tmp/root ]]; then
		mkdir -p /btrfs_tmp/old_roots
		timestamp=$(date "+%Y-%m-%d_%H:%M:%S")
		mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
		fi

		# Cleanup old roots (keep last 5)
		if [[ -d /btrfs_tmp/old_roots ]]; then
			find /btrfs_tmp/old_roots/ -maxdepth 1 -mindepth 1 -type d | sort -r | tail -n +6 | xargs -r btrfs subvolume delete
		fi

		btrfs subvolume snapshot /btrfs_tmp/blank /btrfs_tmp/root

		umount /btrfs_tmp
		'';
	};

	fileSystems."/persistent".neededForBoot = true;

	environment.persistence."/persistent" = {
		hideMounts = true;

		directories = [
			"/var/log"
			"/var/lib/bluetooth"
			"/var/lib/nixos"
			"/var/lib/systemd/coredump"
			"/etc/NetworkManager/system-connections"
			"/var/lib/NetworkManager"
			"/var/lib/systemd/backlight"
		];
		files = [
			"/etc/machine-id"
			"/etc/ssh/ssh_host_ed25519_key"
			"/etc/ssh/ssh_host_rsa_key"
		];

		users.${userName} = {
			directories = [
				"Downloads"
				"Music"
				"Pictures"
				"Documents"
				"Videos"
				{ directory = ".ssh"; mode = "0700"; }
				{ directory = ".gnupg"; mode = "0700"; }
				".local/share/keyrings"
				".local/share/fish"
				".local/share/nvim"
				".local/state/nvim"
				".zen"
				".local/share/zoxide"
				".local/share/yazi"
				".cache/rclone"
				".config/Code - Cursor"
				".local/state/wireplumber"
				".cache/bat"
				".config/sops/age"
			];
		};
	};
}