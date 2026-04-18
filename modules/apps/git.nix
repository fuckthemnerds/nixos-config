{ config, lib, pkgs, globals, inputs, ... }:
let
  cfg = config.apps.git;
in
{
  options.apps.git.enable = lib.mkEnableOption "git";

  config = lib.mkIf cfg.enable {
    home-manager.users.${globals.userName} = { config, ... }: {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];

      sops = {
        defaultSopsFile = ../../secrets/secrets.yaml;
        defaultSopsFormat = "yaml";
        validateSopsFiles = false;
        age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

        secrets.git_user = { };
        secrets.git_email = { };

        templates."git-credentials.ini".content = ''
          [user]
            name = ${config.sops.placeholder.git_user}
            email = ${config.sops.placeholder.git_email}
        '';
      };

      programs.git = {
        enable = true;
        includes = [
          { path = config.sops.templates."git-credentials.ini".path; }
        ];
        extraConfig = {
          init.defaultBranch = "main";
          push.autoSetupRemote = true;
          core.editor = "nvim";
        };
      };
    };
  };
}