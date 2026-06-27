{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.cli;
in {
	options.profiles.cli.enable = lib.mkEnableOption "CLI / terminal tools";

	config =
		lib.mkIf cfg.enable {
			# Terminais
			programs.alacritty.enable = true;
			programs.ghostty.enable = true;

			# Shell / navegação com integração nativa de shell
			programs.zoxide.enable = true;
			programs.fzf.enable = true;
			programs.ripgrep.enable = true;

			# System info
			programs.fastfetch.enable = true;

			home.packages = with pkgs; [
				ueberzugpp
				# tmux gerenciado por profiles.tmux

				# Monitoramento (btop gerenciado por profiles.btop)
				lshw
				lsof
				bmon
				traceroute
				net-tools

				# Arquivamento
				zip
				unzip
				rar
				zstd

				# Texto / dados
				gnugrep
				ripgrep-all
				jq
				mdq
				yq-go
				w3m
				tree
				ncdu
				bc

				# Rede
				curl
				wget
				ntfy-sh

				# Diversão / produtividade
				figlet
				uair
				tt
				hollywood
				translate-shell
				dialog
			];
		};
}
