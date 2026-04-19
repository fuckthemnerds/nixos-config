{ config, pkgs, lib, userName, ... }:

# ── Barebones Aorus ─────────────────────────────────────────────────────────
# Minimal bootable config: hardware, sops, impermanence, networking, users.
# After first boot run: nixos-rebuild switch --flake .#aorus --use-remote-sudo
# ────────────────────────────────────────────────────────────────────────────
{
  # Boot
  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
    };
    initrd.systemd.enable = true;
    kernelParams = [ "quiet" "boot.shell_on_fail" ];
    kernel.sysctl = {
      "vm.swappiness" = 10;
    };

    # Impermanence: rollback root subvol on every boot
    initrd.systemd.services.rollback = {
      description = "Rollback Btrfs root";
      wantedBy    = [ "initrd.target" ];
      after       = [ "initrd-root-device.target" "dev-disk-by\\x2dlabel-nixos.device" ];
      requires    = [ "dev-disk-by\\x2dlabel-nixos.device" ];
      before      = [ "sysroot.mount" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      path   = [ pkgs.btrfs-progs ];
      script = ''
        mkdir -p /btrfs_tmp
        mount -o subvol=/ /dev/disk/by-label/nixos /btrfs_tmp

        if [[ -e /btrfs_tmp/root ]]; then
          mkdir -p /btrfs_tmp/old_roots
          timestamp=$(date "+%Y-%m-%d_%H:%M:%S")
          mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
        fi

        # Keep last 3 old roots
        if [[ -d /btrfs_tmp/old_roots ]]; then
          find /btrfs_tmp/old_roots/ -maxdepth 1 -mindepth 1 -type d \
            | sort -r | tail -n +4 | xargs -r btrfs subvolume delete
        fi

        btrfs subvolume snapshot /btrfs_tmp/blank /btrfs_tmp/root
        umount /btrfs_tmp
      '';
    };
  };

  # Nix
  nix.settings = {
    trusted-users          = [ "root" userName ];
    allowed-users          = [ "@wheel" ];
    experimental-features  = [ "nix-command" "flakes" ];
    auto-optimise-store    = true;
    substituters           = [ "https://nix-community.cachix.org" ];
    trusted-public-keys    = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # Networking
  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowPing = false;
    };
  };
  systemd.services.NetworkManager-wait-online.enable = false;
  services.resolved.enable = true;

  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";

  # SOPS
  sops = {
    defaultSopsFile  = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    validateSopsFiles = false;
    age.keyFile      = "/persistent/var/lib/sops-nix/keys.txt";
    age.sshKeyPaths  = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets."user_password_${userName}" = {
      neededForUsers = true;
      mode = "0440";
    };
  };

  # Users
  users = {
    mutableUsers = false;
    users.${userName} = {
      isNormalUser     = true;
      description      = "Primary User";
      hashedPasswordFile = config.sops.secrets."user_password_${userName}".path;
      extraGroups      = [ "wheel" "networkmanager" "video" "audio" ];
      shell            = pkgs.bash; # bash for barebones; full config switches to fish
    };
  };

  # Impermanence
  fileSystems."/persistent".neededForBoot = true;

  environment.persistence."/persistent" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
      "/var/lib/NetworkManager"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_rsa_key"
    ];
    users.${userName} = {
      directories = [
        "Downloads"
        { directory = ".ssh"; mode = "0700"; }
        ".config/sops/age"
        "nixcfg"
      ];
    };
  };

  # SSH (only way in without a DE)
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Nvidia (required — won't boot graphically without)
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable   = true;
    open                 = false;
    powerManagement.enable = true;
    package              = pkgs.linuxPackages_zen.nvidiaPackages.stable;
    prime.intelBusId     = "PCI:0:2:0";
    prime.nvidiaBusId    = "PCI:1:0:0";
  };

  # Minimal packages to bootstrap / switch to full config
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    age
    sops
  ];

  # zramSwap helps during build
  zramSwap.enable = true;
}
