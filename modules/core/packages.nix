{ pkgs, ... }:

{
	environment.systemPackages = with pkgs; [
		nh                  # Next-gen Nix helper (clean CLI, auto GC)
		nvd                 # Visual diff between generations
		nix-output-monitor
		alejandra
		sops
		age
		gnumake
		nvtopPackages.full  # GPU monitoring (Aorus)
		powertop            # Battery monitoring (Surface)
		acpi                # Lightweight battery/thermal info
		curl
		wget
		unzip
		zip
		p7zip
	];
}