{ ... }:

{
	programs.zoxide = {
		enable = true;
		enableFishIntegration = true;
		options = [ "--cmd z" ];
	};
}
