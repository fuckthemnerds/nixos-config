{ device ? "/dev/nvme0n1", ... }:
{
	disko.devices = {
		disk.main = {
			type = "disk";
			device = device; # To be overridden in install.sh/hardware.nix
			content = {
				type = "gpt";
				partitions = {
					ESP = {
						size = "512M";
						type = "EF00";
						content = {
							type = "filesystem";
							format = "vfat";
							mountpoint = "/boot";
							mountOptions = [ "fmask=0022" "dmask=0022" ];
						};
					};
					swap = {
						size = "8G";
						content = {
							type = "swap";
							discardPolicy = "both";
							resumeDevice = true;
						};
					};
					root = {
						size = "100%";
						content = {
							type = "btrfs";
							extraArgs = [ "-L" "nixos" "-f" ];
							subvolumes = {
								"root" = {
									mountpoint = "/";
									mountOptions = [ "compress=zstd" "noatime" ];
								};
								"blank" = { };
								"nix" = {
									mountpoint = "/nix";
									mountOptions = [ "compress=zstd" "noatime" ];
								};
								"persistent" = {
									mountpoint = "/persistent";
									mountOptions = [ "compress=zstd" "noatime" ];
								};
							};
						};
					};
				};
			};
		};
	};
}