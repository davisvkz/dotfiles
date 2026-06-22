{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.dev.db;
in {
	options.profiles.dev.db.enable = lib.mkEnableOption "Database tools (Redis, PostgreSQL, DBeaver, Prisma, ldb)";

	config =
		lib.mkIf cfg.enable {
			home.sessionVariables = {
				# Prisma engines are downloaded via: cd apps/server && bun run db:download-engine
				# nixpkgs ships prisma-engines for the latest major; pinned versions avoid mismatch.
				PRISMA_SCHEMA_ENGINE_BINARY = "$HOME/.local/share/prisma/schema-engine";
				PRISMA_QUERY_ENGINE_LIBRARY = "$HOME/.local/share/prisma/libquery_engine.so.node";
				PRISMA_ENGINES_CHECKSUM_IGNORE_MISSING = "1";
				# Allow non-NixOS .so files (like Prisma's library engine) to find system libs.
				LD_LIBRARY_PATH = "/run/current-system/sw/share/nix-ld/lib\${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}";
			};

			home.packages = with pkgs; [
				redis
				postgresql
				dbeaver-bin
				lazysql
				termdbms
				supabase-cli
				prisma
				ldb
				sqls
			];
		};
}
