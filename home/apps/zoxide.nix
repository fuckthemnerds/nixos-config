{ ... }:

{
	# ── ZOXIDE (SMART JUMP) ───────────────────────────────────────────────────────
	# A faster way to navigate your filesystem. It learns as you use it.
	programs.zoxide = {
		enable = true;
		enableFishIntegration = true;
		options = [ "--cmd z" ];
	};
}
