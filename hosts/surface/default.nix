{
  pkgs,
  lib,
  userName,
  ...
}: {
  services.auto-cpufreq.enable = true;

  zramSwap.enable = true;
  
  boot.kernel.sysctl = {
    "vm.swappiness" = lib.mkForce 80;
    "vm.page-cluster" = lib.mkForce 0;
    "vm.max_map_count" = 1048576;
  };
}

