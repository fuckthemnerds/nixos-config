{ ... }:

{
  determinate.enable = true;

  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };

  nix.settings = {
    builders-use-substitutes = true;
    cores = 0;

    substituters = [
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}