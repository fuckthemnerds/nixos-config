{
  config,
  pkgs,
  lib,
  userName,
  ...
}: {
  boot.initrd.systemd.services.rollback = {
    description = "Rollback Btrfs root";
    wantedBy = ["initrd.target"];
    after = ["initrd-root-device.target" "dev-disk-by\\x2dlabel-nixos.device"];
    requires = ["dev-disk-by\\x2dlabel-nixos.device"];
    before = ["sysroot.mount"];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";

    path = [pkgs.btrfs-progs pkgs.coreutils pkgs.findutils];
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
        find /btrfs_tmp/old_roots/ -maxdepth 1 -mindepth 1 -type d | sort -r | tail -n +6 | xargs -r -I{} btrfs subvolume delete --recursive {}
      fi

      btrfs subvolume snapshot /btrfs_tmp/blank /btrfs_tmp/root

      umount /btrfs_tmp
    '';
  };

  programs.fuse.userAllowOther = true;

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
      { file = "/etc/ssh/ssh_host_ed25519_key"; parentDirectory = { mode = "0755"; }; }
      "/etc/ssh/ssh_host_ed25519_key.pub"
      { file = "/etc/ssh/ssh_host_rsa_key"; parentDirectory = { mode = "0755"; }; }
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];

    users.${userName} = {
      directories = [
        "nixcfg"
        "Downloads"
        "Music"
        "Pictures"
        "Documents"
        "Videos"
        {
          directory = ".ssh";
          mode = "0700";
        }
        {
          directory = ".gnupg";
          mode = "0700";
        }
        ".local/share/keyrings"
        ".local/share/fish"
        ".local/share/nvim"
        ".local/state/nvim"
        ".local/state/nix"
        ".local/state/home-manager"
        ".local/share/applications"
        ".local/share/icons"
        ".config/dconf"
        ".cache/nix"
        ".zen"
        ".local/share/zoxide"
        ".local/share/yazi"
        ".cache/rclone"
        ".config/Code - Cursor"
        ".local/state/wireplumber"
        ".cache/bat"
        ".config/sops/age"
        ".config/keepassxc"
        ".cache/cliphist"
        ".config/teams-for-linux"
        ".config/libreoffice"
        ".config/git"
        ".config/niri"
        ".config/fish"
        ".config/tridactyl"
      ];
    };
  };
}