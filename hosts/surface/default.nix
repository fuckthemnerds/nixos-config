{
  pkgs,
  userName,
  ...
}: {
  environment.systemPackages = [
    pkgs.nvtopPackages.intel
  ];

  services.auto-cpufreq.enable = true;
  boot.tmp.size = "2G";

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