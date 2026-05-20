# lib/default.nix
{lib, ...}: {
  mkIfEnabled = enable: config: lib.mkIf enable config;
}
