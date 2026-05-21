{
  ...
}: {
  imports = [
    ../nixos/boot/server.nix
  ];

  # Core headless server-appropriate options
  apps = {
    nh.enable = true;
    modern-cli.enable = true;
    zoxide.enable = true;
    yazi.enable = true;
    btop.enable = true;
    fastfetch.enable = true;
    fish.enable = true;
    git.enable = true;
    nvim.enable = true;
  };
}
