{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.nvtopPackages.intel
  ];

  services.auto-cpufreq.enable = true;
  boot.tmp.tmpfsSize = "2G";
}