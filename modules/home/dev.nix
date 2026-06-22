{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.dev;
in {
	options.profiles.dev.enable = lib.mkEnableOption "Development tools and runtimes";

	config = lib.mkIf cfg.enable {
		home.sessionVariables = {
			OMNISHARP_MONO = "${pkgs.mono}/bin/mono";
			# Both engines are downloaded via: cd apps/server && bun run db:download-engine
			# nixpkgs ships prisma-engines for the latest Prisma major; pinned versions avoid mismatch.
			PRISMA_SCHEMA_ENGINE_BINARY = "$HOME/.local/share/prisma/schema-engine";
			PRISMA_QUERY_ENGINE_LIBRARY = "$HOME/.local/share/prisma/libquery_engine.so.node";
			PRISMA_ENGINES_CHECKSUM_IGNORE_MISSING = "1";
			# Allow non-NixOS .so files (like Prisma's library engine) to find system libs.
			LD_LIBRARY_PATH = "/run/current-system/sw/share/nix-ld/lib\${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}";
		};

		home.packages = with pkgs; [
			# JS / TS
			nodejs
			pnpm
			bun
			deno

			# Lua
			(lua5_1.withPackages (ps: with ps; [luarocks]))

			# Go / Rust
			go
			rustc
			cargo

			# Python
			uv
			pipx
			(python3.withPackages (ps:
				with ps; [
					pygobject3
					pycairo
					opencv4
				]))

			# JVM / .NET
			jdk25
			dotnet-sdk_10
			omnisharp-roslyn
			mono
			netcoredbg
			csharpier
			jetbrains.rider
			jetbrains-toolbox

			# C / C++
			gcc
			cmake
			gnumake
			pkg-config

			# Git
			lazygit
			gitkraken
			github-desktop
			git-filter-repo

			# Editores / IDEs
			vscode

			# LSP / formatters
			nixd
			nil
			biome
			sqls

			# Imagens (nvim + imagemagick)
			imagemagick
			luajitPackages.magick

			# Docker
			docker
			docker-credential-helpers
			lazydocker
			docker-compose

			# Bancos de dados
			redis
			postgresql
			dbeaver-bin
			lazysql
			gobang
			termdbms
			supabase-cli
			prisma
			ldb

			# APIs / HTTP
			insomnia
			postman
			redocly
			ngrok
			cloudflared

			# Crypto / pin
			pinentry-curses

			# Libs de desenvolvimento
			openssl
			alsa-lib
			alsa-lib.dev

			# Playwright
			playwright-driver.browsers
			xvfb-run

			# DevOps / infra
			vagrant
			railway

			# Emuladores / fun
			ccemux
			(lib.lowPrio craftos-pc)
		];
	};
}
