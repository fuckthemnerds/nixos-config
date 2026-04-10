{ ... }:

{
	determinateNix = {
		enable = true;

		determinateNixd = {
			garbageCollector = {
				strategy = "automatic";
			};
		};
	};

	environment.etc."nix/nix.custom.conf".text = ''
		eval-cores = 0
		extra-experimental-features = nix-command flakes parallel-eval
	'';
}
