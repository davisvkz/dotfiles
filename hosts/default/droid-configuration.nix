# Configuração nix-on-droid — ambiente de desenvolvimento e terminal.
# Apenas ferramentas CLI/terminal (sem GUI/X11).
{ config, lib, pkgs, flake, ... }:
let
	id = (import "${flake}/lib/settings.nix").identity;
in {
	# ── Sistema ─────────────────────────────────────────────────────────────────
	time.timeZone = id.timezone;
	environment.etcBackupExtension = ".bak";
	system.stateVersion = "24.05";
	nix.extraOptions = ''
		experimental-features = nix-command flakes
		sandbox = false
	'';

	# Shell padrão do usuário
	user.shell = "${pkgs.zsh}/bin/zsh";

	# Pacotes de sistema (base Android-safe, sem dependências de kernel NixOS)
	environment.packages = with pkgs; [
		coreutils
		gnugrep
		gnused
		gawk
		findutils
		diffutils
		procps
		which
		file
		openssh
		man
		bashInteractive
	];

	# ── Home Manager ─────────────────────────────────────────────────────────────
	home-manager = {
		backupFileExtension = "hm-bak";
		useGlobalPkgs = true;
		extraSpecialArgs = { inherit flake; };

		config = { config, lib, pkgs, ... }: {
			imports = [
				# Shell (zsh + dotfiles)
				"${flake}/modules/home/shell.nix"
				# Editor
				"${flake}/modules/home/neovim.nix"
				# Multiplexer de terminal
				"${flake}/modules/home/tmux.nix"
				# Monitor de sistema
				"${flake}/modules/home/btop.nix"
				# File manager
				"${flake}/modules/home/lf.nix"
				# RSS
				"${flake}/modules/home/newsboat.nix"
				# Stacks de desenvolvimento (apenas CLI)
				"${flake}/modules/home/dev/js.nix"
				"${flake}/modules/home/dev/python.nix"
				"${flake}/modules/home/dev/rust.nix"
				"${flake}/modules/home/dev/go.nix"
				"${flake}/modules/home/dev/cpp.nix"
				"${flake}/modules/home/dev/lua.nix"
			];

			# ── Perfis ──────────────────────────────────────────────────────────
			profiles = {
				shell.enable = true;
				neovim.enable = true;
				tmux.enable = true;
				btop.enable = true;
				lf.enable = true;
				newsboat.enable = true;
				dev = {
					js.enable = true;
					python.enable = true;
					rust.enable = true;
					go.enable = true;
					cpp.enable = true;
					lua.enable = true;
				};
			};

			# ── Programas CLI (equivalente a cli.nix, sem GUI e sem rar) ─────────
			programs.zoxide.enable = true;
			programs.fzf.enable = true;
			programs.ripgrep.enable = true;
			programs.fastfetch.enable = true;

			# ── Git (inline — git.nix depende de osConfig, ausente aqui) ─────────
			programs.git = {
				enable = true;
				settings.user = {
					name = id.fullName;
					email = id.email;
				};
			};

			programs.gh = {
				enable = true;
				gitCredentialHelper.enable = true;
			};

			# ── Pacotes ──────────────────────────────────────────────────────────
			home.packages = with pkgs; [
				# CLI / monitoramento
				ueberzugpp
				lshw
				lsof
				bmon
				traceroute
				net-tools

				# Arquivamento (sem rar: não suporta aarch64-linux)
				zip
				unzip
				zstd

				# Texto / dados
				ripgrep-all
				jq
				yq-go
				w3m
				tree
				ncdu
				bc

				# Rede / notificações
				curl
				wget
				ntfy-sh

				# Produtividade / diversão terminal
				figlet
				translate-shell
				dialog

				# Nix LSPs + git avançado
				nixd
				nil
				git-filter-repo
				lazygit

				# DB CLIs (sem partes GUI: sem dbeaver, prisma, etc.)
				postgresql
				redis
				lazysql
				sqls
				termdbms

				# HTTP / API CLIs (sem Insomnia/Postman GUI)
				httpie
				redocly
				ngrok
				cloudflared
			];

			home.stateVersion = "24.05";
		};
	};
}
