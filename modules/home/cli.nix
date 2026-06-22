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
			home.packages = with pkgs; [
				# Terminais
				wezterm
				alacritty
				ghostty

				# Shell / navegação
				lf
				zoxide
				fzf
				ueberzugpp
				tmux

				# Monitoramento
				btop
				lshw
				fastfetch
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
				ripgrep
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
