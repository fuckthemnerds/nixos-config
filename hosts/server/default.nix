
{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../modules/suites/server-suite.nix
  ];

  # Server-specific kernel package selection
  boot.kernelPackages = pkgs.linuxPackages_latest;
}