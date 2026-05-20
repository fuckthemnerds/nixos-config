{...}: {
  security = {
    rtkit.enable = true;
    polkit.enable = true;
    pam = {
      services.hyprlock = {};
      loginLimits = [
        {
          domain = "*";
          item = "maxlogins";
          type = "hard";
          value = "3";
        }
      ];
    };
  };
}
