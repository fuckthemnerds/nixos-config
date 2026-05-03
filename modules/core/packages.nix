{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    nvd # Visual diff between generations
    nix-output-monitor
    alejandra
    sops
    age
    gnumake
    powertop # Battery monitoring (Surface)
    acpi # Lightweight battery/thermal info
    curl
    wget
    unzip
    zip
    _7zz
  ];
}