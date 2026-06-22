{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.security;
in {
	options.profiles.security.enable = lib.mkEnableOption "Security / pentesting tools";

	config =
		lib.mkIf cfg.enable {
			home.packages = with pkgs; [
				# Reconhecimento
				nmap
				gobuster
				dirb
				sherlock

				# Exploração / análise
				metasploit
				sqlmap
				ghauri
				burpsuite
				slowhttptest

				# Análise de binários / memória
				scanmem
				jpexs

				# Auxiliares
				chromedriver
			];
		};
}
