{
  pkgs,
  userName,
  ...
}: {
  environment.systemPackages = [
    pkgs.nvtopPackages.intel
  ];

  services.auto-cpufreq.enable = true;
  boot.tmp.tmpfsSize = "2G";

  boot.initrd.luks.devices."crypted-swap" = {
    device = "/dev/disk/by-partlabel/disk-main-swap";
    allowDiscards = true;
  };

  boot.resumeDevice = "/dev/mapper/crypted-swap";

  services.displayManager.ly.enable = false;

  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "${pkgs.niri}/bin/niri-session";
        user = "${userName}";
      };
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd niri-session";
        user = "greeter";
      };
    };
  };
}