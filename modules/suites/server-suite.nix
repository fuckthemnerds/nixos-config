# -----------------------------------------------------------------------------
#  SUITE: server-suite.nix
#  DESCRIPTION: Configuration suite optimized for headless servers.
#  This profile imports server boot rules and provisions standard CLI
#  development and monitoring packages.
# -----------------------------------------------------------------------------
{
  ...
}: {
  imports = [
    ../nixos/boot-server.nix
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
