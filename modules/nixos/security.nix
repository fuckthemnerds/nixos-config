{ ... }: {

  # ===========================================================================
  # Real-time Scheduling & Policy Kit
  # ===========================================================================
  security = {
    # RealtimeKit system service. Required for Pipewire to acquire high-priority,
    # real-time scheduling (prevents audio dropouts/crackling under heavy load).
    rtkit.enable = true;

    # Polkit authorization manager. Essential for unprivileged desktop processes
    # (e.g. launchers, power managers) to securely perform privileged actions.
    polkit.enable = true;

    # =========================================================================
    # PAM (Pluggable Authentication Modules) & Login Limits
    # =========================================================================
    pam = {
      # Enable a blank PAM rule configuration specifically for hyprlock.
      # Allows hyprlock to safely authenticate user sessions against system PAM.
      services.hyprlock = {};

      # Establish defensive, physical access login ceilings.
      loginLimits = [
        {
          domain = "*";

          item = "maxlogins";

          type = "hard";

          # Allow a maximum of 3 active logins (e.g. local TTY, Wayland, and remote SSH).
          value = "3";
        }
      ];
    };
  };
}
