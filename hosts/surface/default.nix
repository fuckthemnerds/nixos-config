{ pkgs, ... }:
{
  # Toggles features from modules/ (Enabled by default in defaults.nix)

  # Host specific overrides
  # Surface specific kernel/drivers

  environment.systemPackages = [
    pkgs.nvtopPackages.intel
  ];

  services.auto-cpufreq.enable = true;
  boot.tmp.tmpfsSize = "2G";
}