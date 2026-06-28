{
	config,
	lib,
	...
}: let
	cfg = config.profiles.ssh;
	username = config.settings.identity.username;
in {
	options.profiles.ssh.enable = lib.mkEnableOption "Servidor OpenSSH (acesso por chave, rede local)";

	config = lib.mkIf cfg.enable {
		services.openssh = {
			enable = true;
			openFirewall = true;
			settings = {
				PasswordAuthentication = false;
				KbdInteractiveAuthentication = false;
				PermitRootLogin = "no";
			};
		};

		# Chave(s) pública(s) do celular.
		# Gere no celular (Termux/nix-on-droid): ssh-keygen -t ed25519 -C "celular"
		# Depois cole o conteúdo de ~/.ssh/id_ed25519.pub abaixo.
		users.users.${username}.openssh.authorizedKeys.keys = [
			"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID0kOmANXxFEAbEr5YxdM3gFyyv1YdykO2i5rNwvrRvd celular"
		];
	};
}
