#############################################################
#
#  Security - Hardening & System Authentication Policies
#
#############################################################
{...}: {
  security = {
    # Real-time scheduling priority for pipewire/audio
    rtkit.enable = true;

    # User privilege authorization framework
    polkit.enable = true;

    pam = {
      # Screen locker authentication
      services.hyprlock = {};

      # Session and resource limit settings
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
