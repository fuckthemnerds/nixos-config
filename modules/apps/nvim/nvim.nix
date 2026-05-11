{
  config,
  lib,
  pkgs,
  inputs,
  hostName,
  userName,
  ...
}: let
  cfg = config.apps.nvim;
  utils = inputs.nixCats.utils;
  stylixColors = config.lib.stylix.colors;
in {
  options.apps.nvim.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = [inputs.nixCats.homeModules.default];

    home-manager.users.${userName} = {
      xdg.configFile."nvim/lua/stylix_colors.lua".text = ''
        return {
          base00 = "#${stylixColors.base00}",
          base01 = "#${stylixColors.base01}",
          base02 = "#${stylixColors.base02}",
          base03 = "#${stylixColors.base03}",
          base04 = "#${stylixColors.base04}",
          base05 = "#${stylixColors.base05}",
          base06 = "#${stylixColors.base06}",
          base07 = "#${stylixColors.base07}",
          base08 = "#${stylixColors.base08}",
          base09 = "#${stylixColors.base09}",
          base0A = "#${stylixColors.base0A}",
          base0B = "#${stylixColors.base0B}",
          base0C = "#${stylixColors.base0C}",
          base0D = "#${stylixColors.base0D}",
          base0E = "#${stylixColors.base0E}",
          base0F = "#${stylixColors.base0F}",
        }
      '';

      nixCats = {
        enable = true;
        luaPath = "${./lua}";
        packageNames = ["nvim"];

        addOverlays = [(utils.standardPluginOverlay inputs)];

        categoryDefinitions.replace = {
          pkgs,
          settings,
          categories,
          extra,
          name,
          mkPlugin,
          ...
        } @ packageDef: {
          lspsAndRuntimeDeps = {
            general = with pkgs; [
              ripgrep
              fd
            ];
            lsp = with pkgs; [
              nixd
              lua-language-server
              typescript-language-server
              pyright
              tinymist
            ];
            fmt = with pkgs; [
              alejandra
              stylua
              black
            ];
          };

          startupPlugins = {
            general = with pkgs.vimPlugins; [
              lze
              lzextras
              plenary-nvim
              nvim-web-devicons
            ];
          };

          optionalPlugins = {
            general = with pkgs.vimPlugins; [
              lualine-nvim
              noice-nvim
              nvim-notify
              indent-blankline-nvim
              telescope-nvim
              telescope-fzf-native-nvim
              oil-nvim
              flash-nvim
              nvim-autopairs
              gitsigns-nvim
              comment-nvim
              which-key-nvim
              nvim-cmp
              cmp-nvim-lsp
              cmp-buffer
              cmp-path
              luasnip
              cmp_luasnip
              nvim-lspconfig
              conform-nvim
              nvim-treesitter.withAllGrammars
              direnv-vim
              nui-nvim
            ];
          };

          environmentVariables = {};
          extraWrapperArgs = {};
          sharedLibraries = {};
        };

        packageDefinitions.replace = {
          nvim = {pkgs, ...}: {
            settings = {
              wrapRc = true;
              suffix-path = true;
              suffix-LD = true;
              aliases = ["vim" "vi"];
            };
            categories = {
              general = true;
              lsp = true;
              fmt = true;
            };
            extra = {
              nixdExtras = {
                nixosConfig = "(builtins.getFlake \"$" + "{workspaceFolder}\").nixosConfigurations.\"${hostName}\".options";
                hmConfig = "(builtins.getFlake \"$" + "{workspaceFolder}\").nixosConfigurations.\"${hostName}\".options.home-manager.users.type.getSubOptions []";
                nixpkgs = "import ${pkgs.path} {}";
              };
            };
          };
        };
      };
    };
  };
}
