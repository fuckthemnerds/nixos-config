{
  config,
  lib,
  pkgs,
  globals,
  ...
}: let
  cfg = config.apps.fastfetch;
in {
  options.apps.fastfetch.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${globals.userName} = {
      programs.fastfetch = {
        enable = true;
        settings = {
          logo = {
            source = "${pkgs.writeText "fastfetch-logo.txt" ''
                    .    ,-.    .
                   oO\   \  \  / \
                   \OO\   \  \/  /
                ,oO0OO0OOOo\   ,/ o\
               <oOOOOOOOOOOo\  \ /O0;
                    /``/     \  ,OO/
              ,────'  /       \,OOOOoo,
              \___   o\       /0O/OOo>`
                 /  oOO\_____/OO/____
                `  / \OO\    `"`     /
                 \/ /0OOO\~──.  .──~`
                   /OO/\OO\   \  \
                   \0/  \O0\   \  \
                         `"`    `~`
            ''}";
            position = "left";
            padding = {
              top = 1;
              left = 0;
            };
          };
          display = {
            separator = " : ";
          };

          modules = [
            "break"
            {
              type = "custom";
              format = "┌──────────────────────────────────────────────────────────┐";
            }
            "break"
            {
              type = "os";
              key = "                   OS";
            }
            {
              type = "shell";
              key = "                SHELL";
            }
            {
              type = "packages";
              key = "             PACKAGES";
              format = "{nix-system} (Nix)";
            }
            "break"
            {
              type = "custom";
              format = "├──────────────────────────────────────────────────────────┤";
            }
            "break"
            {
              type = "wm";
              key = "                   WM";
            }
            {
              type = "memory";
              key = "                  RAM";
            }
            {
              type = "disk";
              key = "                 DISK";
              folders = "/";
              format = "{1} / {2} ({3})";
            }
            {
              type = "uptime";
              key = "               UPTIME";
            }
            "break"
            {
              type = "custom";
              format = "└──────────────────────────────────────────────────────────┘";
            }
          ];
        };
      };
    };
  };
}
