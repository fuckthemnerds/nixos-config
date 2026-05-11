{
  config,
  lib,
  pkgs,
  inputs,
  userName,
  hostName,
  stateVersion,
  ...
}: {
  determinate.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = {inherit inputs userName stateVersion hostName;};
    sharedModules = [];

    users.${userName} = {
      home.stateVersion = stateVersion;
      home.username = userName;
      home.homeDirectory = lib.mkForce "/home/${userName}";
    };
  };

  users = {
    mutableUsers = false;
    users.${userName} = {
      isNormalUser = true;
      description = "Primary User";
      hashedPasswordFile = config.sops.secrets."user_password_${userName}".path;
      extraGroups = ["wheel" "video" "audio"];
      shell = pkgs.fish;
      createHome = true;
      homeMode = "700";
    };
  };

  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    nvd
    nix-output-monitor
    alejandra
    sops
    age
    gnumake
    powertop
    acpi
    curl
    _7zz
    bluetui
    pulsemixer
  ];

  nix = {
    settings = {
      trusted-users = ["root" userName];
      allowed-users = ["@wheel" userName];
      auto-optimise-store = true;
      builders-use-substitutes = true;
      cores = 0;
      max-jobs = "auto";
      substituters = [
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      experimental-features = ["nix-command" "flakes"];
      warn-dirty = false;
    };

    gc.automatic = false;

    registry = lib.mapAttrs (_: value: {flake = value;}) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
  };

  systemd.settings.Manager = {
    RuntimeWatchdogSec = "30s";
    RebootWatchdogSec = "10m";
  };

  programs.nh = {
    enable = true;
    flake = "/home/${userName}/nixcfg";
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 5";
    };
  };

  zramSwap.enable = true;

}