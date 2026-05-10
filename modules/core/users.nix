{
  config,
  pkgs,
  userName,
  ...
}: {
  users = {
    mutableUsers = false;
    users.${userName} = {
      isNormalUser = true;
      description = "Primary User";
      hashedPasswordFile = config.sops.secrets."user_password_${userName}".path;
      extraGroups = ["wheel" "video" "audio"];
      shell = pkgs.fish;
      createHome = true;
      homeMode = "700";
    };
  };
}