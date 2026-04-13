{ config, lib, pkgs, globals, ... }:
let
	cfg = config.apps.fastfetch;
in
{
	options.apps.fastfetch.enable = lib.mkEnableOption "fastfetch system info";

	config = lib.mkIf cfg.enable {
		home-manager.users.${globals.userName} = {
			programs.fastfetch = {
				enable = true;
				settings = {
					logo = {
						source = "nixos";
						padding = {
							top = 1;
							left = 4;
							right = 2;
						};
					};

					display = {
						separator = ": ";
						constants = [ "─────────────────" ];
					};

					modules = [
						"break"
						"break"
						"break"
						{ type = "custom"; format = "┌{$1} {#1}Hardware Information{#} {$1}┐"; }
						{ type = "display"; key = "Display"; }
						{ type = "cpu"; key = "CPU"; }
						{ type = "gpu"; key = "GPU"; }
						{ type = "disk"; key = "Filesystem"; format = "{filesystem}"; }
						{ type = "disk"; key = "Disk (/persistent)"; folders = "/persistent"; format = "{size-used} / {size-total} [{size-percentage}% used]"; }
						{ type = "memory"; key = "Memory"; format = "{used} / {total} [{percentage}% used]"; }
						{ type = "custom"; format = "├{$1} {#1}Software Information{#} {$1}┤"; }
						{ type = "os"; key = "OS"; }
						{ type = "host"; key = "Host"; }
						{ type = "kernel"; key = "Kernel"; }
						{ type = "shell"; key = "Shell"; }
						{ type = "packages"; key = "Packages"; format = "{nix-system} (nix)"; }
						{ type = "terminalfont"; key = "Font"; format = "{name} ({size}pt)"; }
						{ type = "custom"; format = "└{$1}──────────────────────{$1}┘"; }
					];
				};
			};
		};
	};
}