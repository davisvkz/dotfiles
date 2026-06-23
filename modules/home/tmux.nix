{
	config,
	lib,
	pkgs,
	...
}: let
	cfg = config.profiles.tmux;
in {
	options.profiles.tmux.enable = lib.mkEnableOption "tmux terminal multiplexer";

	config = lib.mkIf cfg.enable {
		programs.tmux = {
			enable = true;
			baseIndex = 1;
			mouse = false;
			prefix = "C-a";
			keyMode = "vi";
			terminal = "tmux-256color";

			plugins = with pkgs.tmuxPlugins; [
				sensible
				nord       # nordtheme/tmux
				resurrect
			];

			extraConfig = ''
				set -ga terminal-overrides ",xterm-256color:RGB"
				set -g pane-base-index 1

				unbind r
				bind r source-file ~/.config/tmux/tmux.conf

				bind b run-shell "tmux setw -g status \$(tmux show -g -w status | grep -q off && echo on || echo off)"

				# vim-like pane navigation
				bind-key h select-pane -L
				bind-key j select-pane -D
				bind-key k select-pane -U
				bind-key l select-pane -R

				# alt+number to switch windows
				bind -n M-1 select-window -t 1
				bind -n M-2 select-window -t 2
				bind -n M-3 select-window -t 3
				bind -n M-4 select-window -t 4
				bind -n M-5 select-window -t 5
				bind -n M-6 select-window -t 6
				bind -n M-7 select-window -t 7
				bind -n M-8 select-window -t 8
				bind -n M-9 select-window -t 9

				# attach session to current pane path
				bind-key M-c attach-session -c "#{pane_current_path}"

				# pass Ctrl+. to applications (e.g. nvim)
				bind-key -n C-. send-keys C-.
			'';
		};
	};
}
