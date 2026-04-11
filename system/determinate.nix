{ ... }:

{
	determinate = {
		enable = true;
	};

	nix.settings = {
		auto-optimise-store = true;
		builders-use-substitutes = true;
		cores = 0;
		extra-experimental-features = [ "nix-command" "flakes" "parallel-eval" ];

		substituters = [
			"https://nix-community.cachix.org"
			"https://niri.cachix.org"
		];
		trusted-public-keys = [
			"nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
			"niri.cachix.org-1:Wv0S7pC9bqfIIDvMtcURP+7U/RIsPszC+V97VInr/H0="
		];
	};
}
