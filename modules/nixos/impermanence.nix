{
  config,
  pkgs,
  lib,
  userName,
  ...
}: {

  # ===========================================================================
  # Boot-time Btrfs Root Rollback
  # ===========================================================================
  # Wipes the root subvolume on boot and restores a clean, blank snapshot.
  # Keeps the previous 5 boots under /old_roots/ for emergency forensics.
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
      # Mount Btrfs parent volume temporarily to manage subvolumes
      mkdir -p /btrfs_tmp
      mount -o subvol=/ /dev/disk/by-label/nixos /btrfs_tmp

      # Move dirty root to old_roots with a unique timestamp
      if [[ -e /btrfs_tmp/root ]]; then
        mkdir -p /btrfs_tmp/old_roots
        timestamp=$(date "+%Y-%m-%d_%H:%M:%S")
        mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
      fi

      # Clean up older historical roots, preserving only the last 5
      if [[ -d /btrfs_tmp/old_roots ]]; then
        find /btrfs_tmp/old_roots/ -maxdepth 1 -mindepth 1 -type d | sort -r | tail -n +6 | xargs -r -I{} btrfs subvolume delete --recursive {}
      fi

      # Re-create a clean, empty root subvolume from the blank template
      btrfs subvolume snapshot /btrfs_tmp/blank /btrfs_tmp/root

      # Unmount and clean up temporary stage
      umount /btrfs_tmp
    '';
  };

  # ===========================================================================
  # System-wide File System & FUSE Settings
  # ===========================================================================
  # Allow non-root users to mount FUSE filesystems with arbitrary user IDs.
  # Required for impermanence mount mapping to function seamlessly.
  programs.fuse.userAllowOther = true;

  # Explicitly declare that /persistent must be mounted before system activation.
  fileSystems."/persistent".neededForBoot = true;

  # ===========================================================================
  # Persistent Storage Rules
  # ===========================================================================
  environment.persistence."/persistent" = {
    hideMounts = true;

    # System-wide directories to persist across boots
    directories = [
      "/var/log"                             # Retain journald system log history.
      "/var/lib/bluetooth"                   # Prevent re-pairing bluetooth peripherals.
      "/var/lib/nixos"                       # Essential system state tracking.
      "/var/lib/systemd/coredump"            # Save application crash logs.
      "/etc/NetworkManager/system-connections" # Saved Wi-Fi and ethernet profiles.
      "/var/lib/NetworkManager"              # NetworkManager operational state.
      "/var/lib/systemd/backlight"           # Preserve display brightness levels.
    ];

    # Crucial system files to persist (e.g., machine identity and host keys)
    files = [
      "/etc/machine-id"                      # Static machine identifier.
      {
        file = "/etc/ssh/ssh_host_ed25519_key";
        parentDirectory = {mode = "0755";};
      }
      "/etc/ssh/ssh_host_ed25519_key.pub"
      {
        file = "/etc/ssh/ssh_host_rsa_key";
        parentDirectory = {mode = "0755";};
      }
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];

    # User-space directories to persist for the primary user
    users.${userName} = {
      directories = [
        "nixcfg"                             # Repository checkout location.
        "Downloads"                          # Temporary browser downloads.
        "Music"                              # Local audio files.
        "Pictures"                           # Local image files.
        "Documents"                          # General user documents.
        "Videos"                             # Local video files.
        "Games"                              # Offline/Native games storage.
        ".local/share/Steam"                 # Steam launcher files.
        ".steam"                             # Steam configuration parameters.
        {
          directory = ".ssh";                # Private user SSH credentials.
          mode = "0700";
        }
        {
          directory = ".gnupg";              # User GPG keychains.
          mode = "0700";
        }
        ".local/share/keyrings"              # GNOME Seahorse/keyring databases.
        ".local/share/fish"                  # Fish shell command history logs.
        ".local/share/nvim"                  # Neovim dynamic state.
        ".local/state/nvim"                  # Neovim persistent settings.
        ".local/state/nix"                   # Nix user profile configurations.
        ".local/state/home-manager"          # Home-manager runtime state.
        ".local/share/applications"          # Custom user desktop launchers.
        ".local/share/icons"                 # Custom cursor and icon sets.
        ".config/dconf"                      # GNOME system setting database.
        ".cache/nix"                         # Nix evaluation cache (speeds up rebuilds).
        ".zen"                               # Zen privacy browser user profiles.
        ".local/share/zoxide"                # Zoxide directory navigation history.
        ".local/share/yazi"                  # Yazi terminal file manager history.
        ".cache/rclone"                      # Cloud synchronization chunk cache.
        ".config/Code - Cursor"              # Cursor IDE user configurations.
        ".local/state/wireplumber"           # Audio volume levels and hardware routes.
        ".cache/bat"                         # syntax theme caches for bat tool.
        ".config/sops/age"                   # Primary SOPS age decryption keys.
        ".config/keepassxc"                  # KeePassXC credentials and database configs.
        ".cache/cliphist"                    # Clipboard manager historical records.
        ".config/teams-for-linux"            # Microsoft Teams desktop configurations.
        ".config/libreoffice"                # LibreOffice suite settings.
        ".config/git"                        # Git local credentials & parameters.
        ".config/niri"                       # Niri window manager config backup.
        ".config/fish"                       # Fish user shell custom settings.
        ".config/tridactyl"                  # Zen browser Tridactyl keybindings.
      ];
    };
  };
}
