{
  config,
  lib,
  pkgs,
  globals,
  inputs,
  myLib,
  ...
}: let
  cfg = config.apps;
in {
  options.apps = {
    nh.enable = myLib.mkEnableOpt "nh Nix CLI";
    steam.enable = myLib.mkEnableOpt "Steam";
    gui-apps.enable = myLib.mkEnableOpt "GUI Apps (Teams, File-Roller, LibreOffice)";
    multimedia.enable = myLib.mkEnableOpt "Multimedia Apps (mpv, imv, etc.)";
    zathura.enable = myLib.mkEnableOpt "Zathura PDF Reader";
    localsend.enable = myLib.mkEnableOpt "LocalSend";
    modern-cli.enable = myLib.mkEnableOpt "Modern CLI tools (ripgrep, fd, eza, bat, fzf)";
    zoxide.enable = myLib.mkEnableOpt "Zoxide";
    yazi.enable = myLib.mkEnableOpt "Yazi File Manager";
    ai.enable = myLib.mkEnableOpt "AI Tools (opencode, antigravity)";
    cliphist.enable = myLib.mkEnableOpt "Cliphist (Clipboard manager)";
    obsidian.enable = myLib.mkEnableOpt "Obsidian note-taking app";
  };

  config = lib.mkMerge [
    ## System Services / Configuration
    (lib.mkIf cfg.nh.enable {
      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep-since 7d --keep 5";
        flake = "/home/${globals.userName}/nixcfg";
      };
    })

    (lib.mkIf cfg.steam.enable {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
      };
    })

    ## Graphical Applications
    (lib.mkIf cfg.gui-apps.enable {
      home-manager.users.${globals.userName}.home.packages = with pkgs; [
        teams-for-linux
        file-roller
        libreoffice-fresh
      ];
    })

    (lib.mkIf cfg.multimedia.enable {
      home-manager.users.${globals.userName}.home.packages = [
        pkgs.imv
        pkgs.mpv
        pkgs.pear-desktop
        inputs.ytm-player.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    })

    (lib.mkIf cfg.zathura.enable {
      home-manager.users.${globals.userName}.programs.zathura = {
        enable = true;
        options = {
          sandbox = "none";
          render-loading = false;
          recolor = true;
          recolor-keephue = true;
        };
        mappings = {
          J = "navigate next";
          K = "navigate previous";
          "<C-i>" = "recolor";
        };
      };
    })

    ## CLI Tools & Utilities
    (lib.mkIf cfg.localsend.enable {
      home-manager.users.${globals.userName}.home.packages = [pkgs.localsend];
      networking.firewall = {
        allowedTCPPorts = [53317];
        allowedUDPPorts = [53317];
      };
    })

    (lib.mkIf cfg.modern-cli.enable {
      home-manager.users.${globals.userName} = {
        programs = {
          ripgrep.enable = true;
          fd.enable = true;
          eza = {
            enable = true;
            git = true;
            icons = "auto";
          };
          bat.enable = true;
          fzf = {
            enable = true;
            enableFishIntegration = true;
          };
        };
        home.packages = [pkgs.imagemagick];
      };
    })

    (lib.mkIf cfg.zoxide.enable {
      home-manager.users.${globals.userName}.programs.zoxide = {
        enable = true;
        enableFishIntegration = true;
        options = ["--cmd z"];
      };
    })

    (lib.mkIf cfg.yazi.enable {
      home-manager.users.${globals.userName}.programs.yazi = {
        enable = true;
        enableFishIntegration = true;
        settings = {
          manager = {
            show_hidden = true;
            sort_by = "natural";
          };
        };
      };
    })

    (lib.mkIf cfg.ai.enable {
      home-manager.users.${globals.userName}.home.packages = with pkgs; [
        opencode
        antigravity
      ];
    })

    (lib.mkIf cfg.cliphist.enable {
      home-manager.users.${globals.userName} = {
        home.packages = [pkgs.cliphist];
        systemd.user.services.cliphist = {
          Unit = {
            Description = "Clipboard history daemon";
            After = ["graphical-session.target"];
            PartOf = ["graphical-session.target"];
          };
          Service = {
            ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
            Restart = "always";
          };
          Install = {
            WantedBy = ["graphical-session.target"];
          };
        };
      };
    })

    (lib.mkIf cfg.obsidian.enable {
      home-manager.users.${globals.userName}.home.packages = [pkgs.obsidian];
    })
  ];
}
