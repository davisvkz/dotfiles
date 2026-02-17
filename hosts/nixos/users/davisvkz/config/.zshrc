# pnpm
export PNPM_HOME="/home/davisvkz/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
export PATH="/home/davisvkz/.cache/.bun/bin:$PATH"
# pnpm end
# Path to your oh-my-zsh installation.
export ZSH="$XDG_CONFIG_HOME/omz"

ZSH_THEME="robbyrussell"
plugins=(git)

# Enable colors and change prompt:
autoload -U colors && colors	# Load colors
PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "
setopt autocd		# Automatically cd into typed directory.
stty stop undef		# Disable ctrl-s to freeze terminal.
setopt interactive_comments

# History in cache directory:
HISTSIZE=10000000
SAVEHIST=10000000
HISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/history"
setopt inc_append_history

# Load aliases and shortcuts if existent.
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutenvrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutenvrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/zshnameddirrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/zshnameddirrc"

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# vi mode
bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Change cursor shape for different vi modes.
function zle-keymap-select () {
    case $KEYMAP in
        vicmd) echo -ne '\e[1 q';;      # block
        viins|main) echo -ne '\e[5 q';; # beam
    esac
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Use lf to switch directories and bind it to ctrl-o
lfcd () {
    tmp="$(mktemp -uq)"
    trap 'rm -f $tmp >/dev/null 2>&1 && trap - HUP INT QUIT TERM PWR EXIT' HUP INT QUIT TERM PWR EXIT
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}
bindkey -s '^o' '^ulfcd\n'

bindkey -s '^a' '^ubc -lq\n'

bindkey -s '^f' '^ucd "$(dirname "$(fzf)")"\n'

bindkey '^[[P' delete-char

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line
bindkey -M vicmd '^[[P' vi-delete-char
bindkey -M vicmd '^e' edit-command-line
bindkey -M visual '^[[P' vi-delete

# Load syntax highlighting; should be last.
source /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh 2>/dev/null

source $ZSH/oh-my-zsh.sh
source <(fzf --zsh)

# Completion files: Use XDG dirs
[ -d "$XDG_CACHE_HOME"/zsh ] || mkdir -p "$XDG_CACHE_HOME"/zsh
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME"/zsh/zcompcache
compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-$ZSH_VERSION

# ZOXIDE
# shellcheck shell=bash

# =============================================================================
#
# Utility functions for zoxide.
#

# pwd based on the value of _ZO_RESOLVE_SYMLINKS.
function __zoxide_pwd() {
    \builtin pwd -L
}

# cd + custom logic based on the value of _ZO_ECHO.
function __zoxide_cd() {
    # shellcheck disable=SC2164
    \builtin cd -- "$@"
}

# =============================================================================
#
# Hook configuration for zoxide.
#

# Hook to add new entries to the database.
function __zoxide_hook() {
    # shellcheck disable=SC2312
    \command zoxide add -- "$(__zoxide_pwd)"
}

# Initialize hook.
\builtin typeset -ga precmd_functions
\builtin typeset -ga chpwd_functions
# shellcheck disable=SC2034,SC2296
precmd_functions=("${(@)precmd_functions:#__zoxide_hook}")
# shellcheck disable=SC2034,SC2296
chpwd_functions=("${(@)chpwd_functions:#__zoxide_hook}")
chpwd_functions+=(__zoxide_hook)

# Report common issues.
function __zoxide_doctor() {
    [[ ${_ZO_DOCTOR:-1} -ne 0 ]] || return 0
    [[ ${chpwd_functions[(Ie)__zoxide_hook]:-} -eq 0 ]] || return 0

    _ZO_DOCTOR=0
    \builtin printf '%s\n' \
        'zoxide: detected a possible configuration issue.' \
        'Please ensure that zoxide is initialized right at the end of your shell configuration file (usually ~/.zshrc).' \
        '' \
        'If the issue persists, consider filing an issue at:' \
        'https://github.com/ajeetdsouza/zoxide/issues' \
        '' \
        'Disable this message by setting _ZO_DOCTOR=0.' \
        '' >&2
}

# =============================================================================
#
# When using zoxide with --no-cmd, alias these internal functions as desired.
#

# Jump to a directory using only keywords.
function __zoxide_z() {
    __zoxide_doctor
    if [[ "$#" -eq 0 ]]; then
        __zoxide_cd ~
    elif [[ "$#" -eq 1 ]] && { [[ -d "$1" ]] || [[ "$1" = '-' ]] || [[ "$1" =~ ^[-+][0-9]$ ]]; }; then
        __zoxide_cd "$1"
    elif [[ "$#" -eq 2 ]] && [[ "$1" = "--" ]]; then
        __zoxide_cd "$2"
    else
        \builtin local result
        # shellcheck disable=SC2312
        result="$(\command zoxide query --exclude "$(__zoxide_pwd)" -- "$@")" && __zoxide_cd "${result}"
    fi
}

# Jump to a directory using interactive search.
function __zoxide_zi() {
    __zoxide_doctor
    \builtin local result
    result="$(\command zoxide query --interactive -- "$@")" && __zoxide_cd "${result}"
}

# =============================================================================
#
# Commands for zoxide. Disable these using --no-cmd.
#

function z() {
    __zoxide_z "$@"
}

function zi() {
    __zoxide_zi "$@"
}

# Completions.
if [[ -o zle ]]; then
    __zoxide_result=''

    function __zoxide_z_complete() {
        # Only show completions when the cursor is at the end of the line.
        # shellcheck disable=SC2154
        [[ "${#words[@]}" -eq "${CURRENT}" ]] || return 0

        if [[ "${#words[@]}" -eq 2 ]]; then
            # Show completions for local directories.
            _cd -/

        elif [[ "${words[-1]}" == '' ]]; then
            # Show completions for Space-Tab.
            # shellcheck disable=SC2086
            __zoxide_result="$(\command zoxide query --exclude "$(__zoxide_pwd || \builtin true)" --interactive -- ${words[2,-1]})" || __zoxide_result=''

            # Set a result to ensure completion doesn't re-run
            compadd -Q ""

            # Bind '\e[0n' to helper function.
            \builtin bindkey '\e[0n' '__zoxide_z_complete_helper'
            # Sends query device status code, which results in a '\e[0n' being sent to console input.
            \builtin printf '\e[5n'

            # Report that the completion was successful, so that we don't fall back
            # to another completion function.
            return 0
        fi
    }

    function __zoxide_z_complete_helper() {
        if [[ -n "${__zoxide_result}" ]]; then
            # shellcheck disable=SC2034,SC2296
            BUFFER="z ${(q-)__zoxide_result}"
            __zoxide_result=''
            \builtin zle reset-prompt
            \builtin zle accept-line
        else
            \builtin zle reset-prompt
        fi
    }
    \builtin zle -N __zoxide_z_complete_helper

    [[ "${+functions[compdef]}" -ne 0 ]] && \compdef __zoxide_z_complete z
fi

# =============================================================================
#
# To initialize zoxide, add this to your shell configuration file (usually ~/.zshrc):
#
# eval "$(zoxide init zsh)"
#
export PATH="/home/davisvkz/.local/share/cargo/bin:$PATH"
export PATH="$HOME/.local/share/go/bin:$PATH"


#
## railway
#


#compdef railway

autoload -U is-at-least

_railway() {
    typeset -A opt_args
    typeset -a _arguments_options
    local ret=1

    if is-at-least 5.2; then
        _arguments_options=(-s -S -C)
    else
        _arguments_options=(-s -C)
    fi

    local context curcontext="$curcontext" state line
    _arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
":: :_railway_commands" \
"*::: :->railway" \
&& ret=0
    case $state in
    (railway)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-command-$line[1]:"
        case $line[1] in
            (add)
_arguments "${_arguments_options[@]}" : \
'*-d+[The name of the database to add]:DATABASE:(postgres mysql redis mongo)' \
'*--database=[The name of the database to add]:DATABASE:(postgres mysql redis mongo)' \
'-s+[The name of the service to create (leave blank for randomly generated)]' \
'--service=[The name of the service to create (leave blank for randomly generated)]' \
'-r+[The repo to link to the service]:REPO:_default' \
'--repo=[The repo to link to the service]:REPO:_default' \
'-i+[The docker image to link to the service]:IMAGE:_default' \
'--image=[The docker image to link to the service]:IMAGE:_default' \
'*-v+[The "{key}={value}" environment variable pair to set the service variables. Example\:]:VARIABLES:_default' \
'*--variables=[The "{key}={value}" environment variable pair to set the service variables. Example\:]:VARIABLES:_default' \
'--verbose=[Verbose logging]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(completion)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
':shell:(bash elvish fish powershell zsh)' \
&& ret=0
;;
(connect)
_arguments "${_arguments_options[@]}" : \
'-e+[Environment to pull variables from (defaults to linked environment)]:ENVIRONMENT:_default' \
'--environment=[Environment to pull variables from (defaults to linked environment)]:ENVIRONMENT:_default' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
'::service_name -- The name of the database to connect to:_default' \
&& ret=0
;;
(deploy)
_arguments "${_arguments_options[@]}" : \
'*-t+[The code of the template to deploy]:TEMPLATE:_default' \
'*--template=[The code of the template to deploy]:TEMPLATE:_default' \
'*-v+[The "{key}={value}" environment variable pair to set the template variables]:VARIABLE:_default' \
'*--variable=[The "{key}={value}" environment variable pair to set the template variables]:VARIABLE:_default' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(deployment)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
":: :_railway__deployment_commands" \
"*::: :->deployment" \
&& ret=0

    case $state in
    (deployment)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-deployment-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
'-s+[Service name or ID to list deployments for (defaults to linked service)]:SERVICE:_default' \
'--service=[Service name or ID to list deployments for (defaults to linked service)]:SERVICE:_default' \
'-e+[Environment to list deployments from (defaults to linked environment)]:ENVIRONMENT:_default' \
'--environment=[Environment to list deployments from (defaults to linked environment)]:ENVIRONMENT:_default' \
'--limit=[Maximum number of deployments to show (default\: 20, max\: 1000)]:LIMIT:_default' \
'--json[Output in JSON format]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(up)
_arguments "${_arguments_options[@]}" : \
'-s+[Service to deploy to (defaults to linked service)]:SERVICE:_default' \
'--service=[Service to deploy to (defaults to linked service)]:SERVICE:_default' \
'-e+[Environment to deploy to (defaults to linked environment)]:ENVIRONMENT:_default' \
'--environment=[Environment to deploy to (defaults to linked environment)]:ENVIRONMENT:_default' \
'-d[Don'\''t attach to the log stream]' \
'--detach[Don'\''t attach to the log stream]' \
'-c[Stream build logs only, then exit (equivalent to setting \$CI=true)]' \
'--ci[Stream build logs only, then exit (equivalent to setting \$CI=true)]' \
'--no-gitignore[Don'\''t ignore paths from .gitignore]' \
'--path-as-root[Use the path argument as the prefix for the archive instead of the project directory]' \
'--verbose[Verbose output]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
'::path:_files' \
&& ret=0
;;
(redeploy)
_arguments "${_arguments_options[@]}" : \
'-s+[The service ID/name to redeploy from]:SERVICE:_default' \
'--service=[The service ID/name to redeploy from]:SERVICE:_default' \
'-y[Skip confirmation dialog]' \
'--yes[Skip confirmation dialog]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_railway__deployment__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-deployment-help-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(up)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(redeploy)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(dev)
_arguments "${_arguments_options[@]}" : \
'-v[Show verbose domain replacement info (for default '\''up'\'' command)]' \
'--verbose[Show verbose domain replacement info (for default '\''up'\'' command)]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
":: :_railway__dev_commands" \
"*::: :->dev" \
&& ret=0

    case $state in
    (dev)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-dev-command-$line[1]:"
        case $line[1] in
            (up)
_arguments "${_arguments_options[@]}" : \
'-e+[Environment to use (defaults to linked environment)]:ENVIRONMENT:_default' \
'--environment=[Environment to use (defaults to linked environment)]:ENVIRONMENT:_default' \
'-o+[Output path for docker-compose.yml (defaults to ~/.railway/develop/<project_id>/docker-compose.yml)]:OUTPUT:_files' \
'--output=[Output path for docker-compose.yml (defaults to ~/.railway/develop/<project_id>/docker-compose.yml)]:OUTPUT:_files' \
'--dry-run[Only generate docker-compose.yml, don'\''t run docker compose up]' \
'--no-https[Disable HTTPS and pretty URLs (use localhost instead)]' \
'-v[Show verbose domain replacement info]' \
'--verbose[Show verbose domain replacement info]' \
'--no-tui[Disable TUI, stream logs to stdout instead]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(down)
_arguments "${_arguments_options[@]}" : \
'-o+[Output path for docker-compose.yml (defaults to ~/.railway/develop/<project_id>/docker-compose.yml)]:OUTPUT:_files' \
'--output=[Output path for docker-compose.yml (defaults to ~/.railway/develop/<project_id>/docker-compose.yml)]:OUTPUT:_files' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(clean)
_arguments "${_arguments_options[@]}" : \
'-o+[Output path for docker-compose.yml (defaults to ~/.railway/develop/<project_id>/docker-compose.yml)]:OUTPUT:_files' \
'--output=[Output path for docker-compose.yml (defaults to ~/.railway/develop/<project_id>/docker-compose.yml)]:OUTPUT:_files' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(configure)
_arguments "${_arguments_options[@]}" : \
'--service=[Specific service to configure (by name)]:SERVICE:_default' \
'--remove=[Remove configuration for a service (optionally specify service name)]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_railway__dev__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-dev-help-command-$line[1]:"
        case $line[1] in
            (up)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(down)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(clean)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(configure)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(develop)
_arguments "${_arguments_options[@]}" : \
'-v[Show verbose domain replacement info (for default '\''up'\'' command)]' \
'--verbose[Show verbose domain replacement info (for default '\''up'\'' command)]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
":: :_railway__dev_commands" \
"*::: :->dev" \
&& ret=0

    case $state in
    (dev)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-dev-command-$line[1]:"
        case $line[1] in
            (up)
_arguments "${_arguments_options[@]}" : \
'-e+[Environment to use (defaults to linked environment)]:ENVIRONMENT:_default' \
'--environment=[Environment to use (defaults to linked environment)]:ENVIRONMENT:_default' \
'-o+[Output path for docker-compose.yml (defaults to ~/.railway/develop/<project_id>/docker-compose.yml)]:OUTPUT:_files' \
'--output=[Output path for docker-compose.yml (defaults to ~/.railway/develop/<project_id>/docker-compose.yml)]:OUTPUT:_files' \
'--dry-run[Only generate docker-compose.yml, don'\''t run docker compose up]' \
'--no-https[Disable HTTPS and pretty URLs (use localhost instead)]' \
'-v[Show verbose domain replacement info]' \
'--verbose[Show verbose domain replacement info]' \
'--no-tui[Disable TUI, stream logs to stdout instead]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(down)
_arguments "${_arguments_options[@]}" : \
'-o+[Output path for docker-compose.yml (defaults to ~/.railway/develop/<project_id>/docker-compose.yml)]:OUTPUT:_files' \
'--output=[Output path for docker-compose.yml (defaults to ~/.railway/develop/<project_id>/docker-compose.yml)]:OUTPUT:_files' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(clean)
_arguments "${_arguments_options[@]}" : \
'-o+[Output path for docker-compose.yml (defaults to ~/.railway/develop/<project_id>/docker-compose.yml)]:OUTPUT:_files' \
'--output=[Output path for docker-compose.yml (defaults to ~/.railway/develop/<project_id>/docker-compose.yml)]:OUTPUT:_files' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(configure)
_arguments "${_arguments_options[@]}" : \
'--service=[Specific service to configure (by name)]:SERVICE:_default' \
'--remove=[Remove configuration for a service (optionally specify service name)]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_railway__dev__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-dev-help-command-$line[1]:"
        case $line[1] in
            (up)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(down)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(clean)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(configure)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(domain)
_arguments "${_arguments_options[@]}" : \
'-p+[The port to connect to the domain]:PORT:_default' \
'--port=[The port to connect to the domain]:PORT:_default' \
'-s+[The name of the service to generate the domain for]:SERVICE:_default' \
'--service=[The name of the service to generate the domain for]:SERVICE:_default' \
'--json[Output in JSON format]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'-V[Print version]' \
'--version[Print version]' \
'::domain -- Optionally, specify a custom domain to use. If not specified, a domain will be generated:_default' \
&& ret=0
;;
(docs)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(down)
_arguments "${_arguments_options[@]}" : \
'-s+[Service to remove the deployment from (defaults to linked service)]:SERVICE:_default' \
'--service=[Service to remove the deployment from (defaults to linked service)]:SERVICE:_default' \
'-e+[Environment to remove the deployment from (defaults to linked environment)]:ENVIRONMENT:_default' \
'--environment=[Environment to remove the deployment from (defaults to linked environment)]:ENVIRONMENT:_default' \
'-y[Skip confirmation dialog]' \
'--yes[Skip confirmation dialog]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(environment)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
'::environment -- The environment to link to:_default' \
":: :_railway__environment_commands" \
"*::: :->environment" \
&& ret=0

    case $state in
    (environment)
        words=($line[2] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-environment-command-$line[2]:"
        case $line[2] in
            (new)
_arguments "${_arguments_options[@]}" : \
'-d+[The name of the environment to duplicate]:DUPLICATE:_default' \
'-c+[The name of the environment to duplicate]:DUPLICATE:_default' \
'--duplicate=[The name of the environment to duplicate]:DUPLICATE:_default' \
'--copy=[The name of the environment to duplicate]:DUPLICATE:_default' \
'*-v+[Variables to assign in the new environment]:SERVICE:_default:SERVICE:_default' \
'*--service-variable=[Variables to assign in the new environment]:SERVICE:_default:SERVICE:_default' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'-V[Print version]' \
'--version[Print version]' \
'::name -- The name of the environment to create:_default' \
&& ret=0
;;
(delete)
_arguments "${_arguments_options[@]}" : \
'-y[Skip confirmation dialog]' \
'--yes[Skip confirmation dialog]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
'::environment -- The environment to delete:_default' \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" : \
'-y[Skip confirmation dialog]' \
'--yes[Skip confirmation dialog]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
'::environment -- The environment to delete:_default' \
&& ret=0
;;
(rm)
_arguments "${_arguments_options[@]}" : \
'-y[Skip confirmation dialog]' \
'--yes[Skip confirmation dialog]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
'::environment -- The environment to delete:_default' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_railway__environment__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-environment-help-command-$line[1]:"
        case $line[1] in
            (new)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(delete)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(env)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
'::environment -- The environment to link to:_default' \
":: :_railway__environment_commands" \
"*::: :->environment" \
&& ret=0

    case $state in
    (environment)
        words=($line[2] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-environment-command-$line[2]:"
        case $line[2] in
            (new)
_arguments "${_arguments_options[@]}" : \
'-d+[The name of the environment to duplicate]:DUPLICATE:_default' \
'-c+[The name of the environment to duplicate]:DUPLICATE:_default' \
'--duplicate=[The name of the environment to duplicate]:DUPLICATE:_default' \
'--copy=[The name of the environment to duplicate]:DUPLICATE:_default' \
'*-v+[Variables to assign in the new environment]:SERVICE:_default:SERVICE:_default' \
'*--service-variable=[Variables to assign in the new environment]:SERVICE:_default:SERVICE:_default' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'-V[Print version]' \
'--version[Print version]' \
'::name -- The name of the environment to create:_default' \
&& ret=0
;;
(delete)
_arguments "${_arguments_options[@]}" : \
'-y[Skip confirmation dialog]' \
'--yes[Skip confirmation dialog]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
'::environment -- The environment to delete:_default' \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" : \
'-y[Skip confirmation dialog]' \
'--yes[Skip confirmation dialog]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
'::environment -- The environment to delete:_default' \
&& ret=0
;;
(rm)
_arguments "${_arguments_options[@]}" : \
'-y[Skip confirmation dialog]' \
'--yes[Skip confirmation dialog]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
'::environment -- The environment to delete:_default' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_railway__environment__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-environment-help-command-$line[1]:"
        case $line[1] in
            (new)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(delete)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(init)
_arguments "${_arguments_options[@]}" : \
'-n+[Project name]:NAME:_default' \
'--name=[Project name]:NAME:_default' \
'-w+[Workspace ID or name]:WORKSPACE:_default' \
'--workspace=[Workspace ID or name]:WORKSPACE:_default' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(link)
_arguments "${_arguments_options[@]}" : \
'-e+[Environment to link to]:ENVIRONMENT:_default' \
'--environment=[Environment to link to]:ENVIRONMENT:_default' \
'-p+[Project to link to]:PROJECT:_default' \
'--project=[Project to link to]:PROJECT:_default' \
'-s+[The service to link to]:SERVICE:_default' \
'--service=[The service to link to]:SERVICE:_default' \
'-t+[The team to link to (deprecated\: use --workspace instead)]:TEAM:_default' \
'--team=[The team to link to (deprecated\: use --workspace instead)]:TEAM:_default' \
'-w+[The workspace to link to]:WORKSPACE:_default' \
'--workspace=[The workspace to link to]:WORKSPACE:_default' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(list)
_arguments "${_arguments_options[@]}" : \
'--json[Output in JSON format]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(login)
_arguments "${_arguments_options[@]}" : \
'-b[Browserless login]' \
'--browserless[Browserless login]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(logout)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(logs)
_arguments "${_arguments_options[@]}" : \
'-s+[Service to view logs from (defaults to linked service). Can be service name or service ID]:SERVICE:_default' \
'--service=[Service to view logs from (defaults to linked service). Can be service name or service ID]:SERVICE:_default' \
'-e+[Environment to view logs from (defaults to linked environment). Can be environment name or environment ID]:ENVIRONMENT:_default' \
'--environment=[Environment to view logs from (defaults to linked environment). Can be environment name or environment ID]:ENVIRONMENT:_default' \
'-n+[Number of log lines to fetch (disables streaming)]:LINES:_default' \
'--lines=[Number of log lines to fetch (disables streaming)]:LINES:_default' \
'--tail=[Number of log lines to fetch (disables streaming)]:LINES:_default' \
'-f+[Filter logs using Railway'\''s query syntax]:FILTER:_default' \
'--filter=[Filter logs using Railway'\''s query syntax]:FILTER:_default' \
'-d[Show deployment logs]' \
'--deployment[Show deployment logs]' \
'-b[Show build logs]' \
'--build[Show build logs]' \
'--json[Output logs in JSON format. Each log line becomes a JSON object with timestamp, message, and any other attributes]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'-V[Print version]' \
'--version[Print version]' \
'::deployment_id -- Deployment ID to view logs from. Defaults to most recent successful deployment, or latest deployment if none succeeded:_default' \
&& ret=0
;;
(open)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(run)
_arguments "${_arguments_options[@]}" : \
'-s+[Service to pull variables from (defaults to linked service)]:SERVICE:_default' \
'--service=[Service to pull variables from (defaults to linked service)]:SERVICE:_default' \
'-e+[Environment to pull variables from (defaults to linked environment)]:ENVIRONMENT:_default' \
'--environment=[Environment to pull variables from (defaults to linked environment)]:ENVIRONMENT:_default' \
'--no-local[Skip local develop overrides even if docker-compose.yml exists]' \
'-v[Show verbose domain replacement info]' \
'--verbose[Show verbose domain replacement info]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
'*::args -- Args to pass to the command:_default' \
&& ret=0
;;
(service)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
'::service -- The service ID/name to link (deprecated\: use '\''service link'\'' instead):_default' \
":: :_railway__service_commands" \
"*::: :->service" \
&& ret=0

    case $state in
    (service)
        words=($line[2] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-service-command-$line[2]:"
        case $line[2] in
            (link)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
'::service -- The service ID/name to link:_default' \
&& ret=0
;;
(status)
_arguments "${_arguments_options[@]}" : \
'-s+[Service name or ID to show status for (defaults to linked service)]:SERVICE:_default' \
'--service=[Service name or ID to show status for (defaults to linked service)]:SERVICE:_default' \
'-e+[Environment to check status in (defaults to linked environment)]:ENVIRONMENT:_default' \
'--environment=[Environment to check status in (defaults to linked environment)]:ENVIRONMENT:_default' \
'-a[Show status for all services in the environment]' \
'--all[Show status for all services in the environment]' \
'--json[Output in JSON format]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_railway__service__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-service-help-command-$line[1]:"
        case $line[1] in
            (link)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(status)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(shell)
_arguments "${_arguments_options[@]}" : \
'-s+[Service to pull variables from (defaults to linked service)]:SERVICE:_default' \
'--service=[Service to pull variables from (defaults to linked service)]:SERVICE:_default' \
'--silent[Open shell without banner]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(ssh)
_arguments "${_arguments_options[@]}" : \
'-p+[Project to connect to (defaults to linked project)]:PROJECT:_default' \
'--project=[Project to connect to (defaults to linked project)]:PROJECT:_default' \
'-s+[Service to connect to (defaults to linked service)]:SERVICE:_default' \
'--service=[Service to connect to (defaults to linked service)]:SERVICE:_default' \
'-e+[Environment to connect to (defaults to linked environment)]:ENVIRONMENT:_default' \
'--environment=[Environment to connect to (defaults to linked environment)]:ENVIRONMENT:_default' \
'-d+[Deployment instance ID to connect to (defaults to first active instance)]:deployment-instance-id:_default' \
'--deployment-instance=[Deployment instance ID to connect to (defaults to first active instance)]:deployment-instance-id:_default' \
'--session=[SSH into the service inside a tmux session. Installs tmux if it'\''s not installed. Optionally, provide a session name (--session name)]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
'*::command -- Command to execute instead of starting an interactive shell:_default' \
&& ret=0
;;
(starship)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(status)
_arguments "${_arguments_options[@]}" : \
'--json[Output in JSON format]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(unlink)
_arguments "${_arguments_options[@]}" : \
'-s[Unlink a service]' \
'--service[Unlink a service]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(up)
_arguments "${_arguments_options[@]}" : \
'-s+[Service to deploy to (defaults to linked service)]:SERVICE:_default' \
'--service=[Service to deploy to (defaults to linked service)]:SERVICE:_default' \
'-e+[Environment to deploy to (defaults to linked environment)]:ENVIRONMENT:_default' \
'--environment=[Environment to deploy to (defaults to linked environment)]:ENVIRONMENT:_default' \
'-d[Don'\''t attach to the log stream]' \
'--detach[Don'\''t attach to the log stream]' \
'-c[Stream build logs only, then exit (equivalent to setting \$CI=true)]' \
'--ci[Stream build logs only, then exit (equivalent to setting \$CI=true)]' \
'--no-gitignore[Don'\''t ignore paths from .gitignore]' \
'--path-as-root[Use the path argument as the prefix for the archive instead of the project directory]' \
'--verbose[Verbose output]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
'::path:_files' \
&& ret=0
;;
(variables)
_arguments "${_arguments_options[@]}" : \
'-s+[The service to show/set variables for]:SERVICE:_default' \
'--service=[The service to show/set variables for]:SERVICE:_default' \
'-e+[The environment to show/set variables for]:ENVIRONMENT:_default' \
'--environment=[The environment to show/set variables for]:ENVIRONMENT:_default' \
'*--set=[The "{key}={value}" environment variable pair to set the service variables. Example\:]:SET:_default' \
'-k[Show variables in KV format]' \
'--kv[Show variables in KV format]' \
'--json[Output in JSON format]' \
'--skip-deploys[Skip triggering deploys when setting variables]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(whoami)
_arguments "${_arguments_options[@]}" : \
'--json[Output in JSON format]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(volume)
_arguments "${_arguments_options[@]}" : \
'-s+[Service ID]:SERVICE:_default' \
'--service=[Service ID]:SERVICE:_default' \
'-e+[Environment ID]:ENVIRONMENT:_default' \
'--environment=[Environment ID]:ENVIRONMENT:_default' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
":: :_railway__volume_commands" \
"*::: :->volume" \
&& ret=0

    case $state in
    (volume)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-volume-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(add)
_arguments "${_arguments_options[@]}" : \
'-m+[The mount path of the volume]:MOUNT_PATH:_default' \
'--mount-path=[The mount path of the volume]:MOUNT_PATH:_default' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(delete)
_arguments "${_arguments_options[@]}" : \
'-v+[The ID/name of the volume you wish to delete]:VOLUME:_default' \
'--volume=[The ID/name of the volume you wish to delete]:VOLUME:_default' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(update)
_arguments "${_arguments_options[@]}" : \
'-v+[The ID/name of the volume you wish to update]:VOLUME:_default' \
'--volume=[The ID/name of the volume you wish to update]:VOLUME:_default' \
'-m+[The new mount path of the volume (optional)]:MOUNT_PATH:_default' \
'--mount-path=[The new mount path of the volume (optional)]:MOUNT_PATH:_default' \
'-n+[The new name of the volume (optional)]:NAME:_default' \
'--name=[The new name of the volume (optional)]:NAME:_default' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(detach)
_arguments "${_arguments_options[@]}" : \
'-v+[The ID/name of the volume you wish to detach]:VOLUME:_default' \
'--volume=[The ID/name of the volume you wish to detach]:VOLUME:_default' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(attach)
_arguments "${_arguments_options[@]}" : \
'-v+[The ID/name of the volume you wish to attach]:VOLUME:_default' \
'--volume=[The ID/name of the volume you wish to attach]:VOLUME:_default' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_railway__volume__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-volume-help-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(add)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(delete)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(update)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(detach)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(attach)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(redeploy)
_arguments "${_arguments_options[@]}" : \
'-s+[The service ID/name to redeploy from]:SERVICE:_default' \
'--service=[The service ID/name to redeploy from]:SERVICE:_default' \
'-y[Skip confirmation dialog]' \
'--yes[Skip confirmation dialog]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(scale)
_arguments "${_arguments_options[@]}" : \
'-s+[The service to scale (defaults to linked service)]:SERVICE:_default' \
'--service=[The service to scale (defaults to linked service)]:SERVICE:_default' \
'-e+[The environment the service is in (defaults to linked environment)]:ENVIRONMENT:_default' \
'--environment=[The environment the service is in (defaults to linked environment)]:ENVIRONMENT:_default' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(check_updates)
_arguments "${_arguments_options[@]}" : \
'--json[Output in JSON format]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(functions)
_arguments "${_arguments_options[@]}" : \
'-e+[Environment ID/name]:ENVIRONMENT:_default' \
'--environment=[Environment ID/name]:ENVIRONMENT:_default' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
":: :_railway__functions_commands" \
"*::: :->functions" \
&& ret=0

    case $state in
    (functions)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-functions-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(ls)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(new)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the function locally]:PATH:_files' \
'--path=[The path to the function locally]:PATH:_files' \
'-n+[The name of the function]:NAME:_default' \
'--name=[The name of the function]:NAME:_default' \
'-c+[Cron schedule to run the function]:CRON:_default' \
'--cron=[Cron schedule to run the function]:CRON:_default' \
'--http=[Generate a domain]' \
'-s+[Serverless (a.k.a sleeping)]' \
'--serverless=[Serverless (a.k.a sleeping)]' \
'-w+[Watch for changes of the file and deploy upon save]' \
'--watch=[Watch for changes of the file and deploy upon save]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(create)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the function locally]:PATH:_files' \
'--path=[The path to the function locally]:PATH:_files' \
'-n+[The name of the function]:NAME:_default' \
'--name=[The name of the function]:NAME:_default' \
'-c+[Cron schedule to run the function]:CRON:_default' \
'--cron=[Cron schedule to run the function]:CRON:_default' \
'--http=[Generate a domain]' \
'-s+[Serverless (a.k.a sleeping)]' \
'--serverless=[Serverless (a.k.a sleeping)]' \
'-w+[Watch for changes of the file and deploy upon save]' \
'--watch=[Watch for changes of the file and deploy upon save]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(delete)
_arguments "${_arguments_options[@]}" : \
'-f+[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'--function=[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'-y+[Skip confirmation for deleting]' \
'--yes=[Skip confirmation for deleting]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" : \
'-f+[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'--function=[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'-y+[Skip confirmation for deleting]' \
'--yes=[Skip confirmation for deleting]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(rm)
_arguments "${_arguments_options[@]}" : \
'-f+[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'--function=[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'-y+[Skip confirmation for deleting]' \
'--yes=[Skip confirmation for deleting]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(push)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the function]:PATH:_files' \
'--path=[The path to the function]:PATH:_files' \
'-w+[Watch for changes of the file and deploy upon save]' \
'--watch=[Watch for changes of the file and deploy upon save]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(up)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the function]:PATH:_files' \
'--path=[The path to the function]:PATH:_files' \
'-w+[Watch for changes of the file and deploy upon save]' \
'--watch=[Watch for changes of the file and deploy upon save]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(pull)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the function]:PATH:_files' \
'--path=[The path to the function]:PATH:_files' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(link)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the file]:PATH:_files' \
'--path=[The path to the file]:PATH:_files' \
'-f+[The ID/name of the function you wish to link to]:FUNCTION:_default' \
'--function=[The ID/name of the function you wish to link to]:FUNCTION:_default' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_railway__functions__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-functions-help-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(new)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(delete)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(push)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(pull)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(link)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(function)
_arguments "${_arguments_options[@]}" : \
'-e+[Environment ID/name]:ENVIRONMENT:_default' \
'--environment=[Environment ID/name]:ENVIRONMENT:_default' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
":: :_railway__functions_commands" \
"*::: :->functions" \
&& ret=0

    case $state in
    (functions)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-functions-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(ls)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(new)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the function locally]:PATH:_files' \
'--path=[The path to the function locally]:PATH:_files' \
'-n+[The name of the function]:NAME:_default' \
'--name=[The name of the function]:NAME:_default' \
'-c+[Cron schedule to run the function]:CRON:_default' \
'--cron=[Cron schedule to run the function]:CRON:_default' \
'--http=[Generate a domain]' \
'-s+[Serverless (a.k.a sleeping)]' \
'--serverless=[Serverless (a.k.a sleeping)]' \
'-w+[Watch for changes of the file and deploy upon save]' \
'--watch=[Watch for changes of the file and deploy upon save]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(create)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the function locally]:PATH:_files' \
'--path=[The path to the function locally]:PATH:_files' \
'-n+[The name of the function]:NAME:_default' \
'--name=[The name of the function]:NAME:_default' \
'-c+[Cron schedule to run the function]:CRON:_default' \
'--cron=[Cron schedule to run the function]:CRON:_default' \
'--http=[Generate a domain]' \
'-s+[Serverless (a.k.a sleeping)]' \
'--serverless=[Serverless (a.k.a sleeping)]' \
'-w+[Watch for changes of the file and deploy upon save]' \
'--watch=[Watch for changes of the file and deploy upon save]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(delete)
_arguments "${_arguments_options[@]}" : \
'-f+[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'--function=[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'-y+[Skip confirmation for deleting]' \
'--yes=[Skip confirmation for deleting]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" : \
'-f+[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'--function=[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'-y+[Skip confirmation for deleting]' \
'--yes=[Skip confirmation for deleting]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(rm)
_arguments "${_arguments_options[@]}" : \
'-f+[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'--function=[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'-y+[Skip confirmation for deleting]' \
'--yes=[Skip confirmation for deleting]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(push)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the function]:PATH:_files' \
'--path=[The path to the function]:PATH:_files' \
'-w+[Watch for changes of the file and deploy upon save]' \
'--watch=[Watch for changes of the file and deploy upon save]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(up)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the function]:PATH:_files' \
'--path=[The path to the function]:PATH:_files' \
'-w+[Watch for changes of the file and deploy upon save]' \
'--watch=[Watch for changes of the file and deploy upon save]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(pull)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the function]:PATH:_files' \
'--path=[The path to the function]:PATH:_files' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(link)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the file]:PATH:_files' \
'--path=[The path to the file]:PATH:_files' \
'-f+[The ID/name of the function you wish to link to]:FUNCTION:_default' \
'--function=[The ID/name of the function you wish to link to]:FUNCTION:_default' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_railway__functions__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-functions-help-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(new)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(delete)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(push)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(pull)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(link)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(func)
_arguments "${_arguments_options[@]}" : \
'-e+[Environment ID/name]:ENVIRONMENT:_default' \
'--environment=[Environment ID/name]:ENVIRONMENT:_default' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
":: :_railway__functions_commands" \
"*::: :->functions" \
&& ret=0

    case $state in
    (functions)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-functions-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(ls)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(new)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the function locally]:PATH:_files' \
'--path=[The path to the function locally]:PATH:_files' \
'-n+[The name of the function]:NAME:_default' \
'--name=[The name of the function]:NAME:_default' \
'-c+[Cron schedule to run the function]:CRON:_default' \
'--cron=[Cron schedule to run the function]:CRON:_default' \
'--http=[Generate a domain]' \
'-s+[Serverless (a.k.a sleeping)]' \
'--serverless=[Serverless (a.k.a sleeping)]' \
'-w+[Watch for changes of the file and deploy upon save]' \
'--watch=[Watch for changes of the file and deploy upon save]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(create)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the function locally]:PATH:_files' \
'--path=[The path to the function locally]:PATH:_files' \
'-n+[The name of the function]:NAME:_default' \
'--name=[The name of the function]:NAME:_default' \
'-c+[Cron schedule to run the function]:CRON:_default' \
'--cron=[Cron schedule to run the function]:CRON:_default' \
'--http=[Generate a domain]' \
'-s+[Serverless (a.k.a sleeping)]' \
'--serverless=[Serverless (a.k.a sleeping)]' \
'-w+[Watch for changes of the file and deploy upon save]' \
'--watch=[Watch for changes of the file and deploy upon save]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(delete)
_arguments "${_arguments_options[@]}" : \
'-f+[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'--function=[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'-y+[Skip confirmation for deleting]' \
'--yes=[Skip confirmation for deleting]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" : \
'-f+[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'--function=[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'-y+[Skip confirmation for deleting]' \
'--yes=[Skip confirmation for deleting]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(rm)
_arguments "${_arguments_options[@]}" : \
'-f+[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'--function=[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'-y+[Skip confirmation for deleting]' \
'--yes=[Skip confirmation for deleting]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(push)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the function]:PATH:_files' \
'--path=[The path to the function]:PATH:_files' \
'-w+[Watch for changes of the file and deploy upon save]' \
'--watch=[Watch for changes of the file and deploy upon save]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(up)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the function]:PATH:_files' \
'--path=[The path to the function]:PATH:_files' \
'-w+[Watch for changes of the file and deploy upon save]' \
'--watch=[Watch for changes of the file and deploy upon save]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(pull)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the function]:PATH:_files' \
'--path=[The path to the function]:PATH:_files' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(link)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the file]:PATH:_files' \
'--path=[The path to the file]:PATH:_files' \
'-f+[The ID/name of the function you wish to link to]:FUNCTION:_default' \
'--function=[The ID/name of the function you wish to link to]:FUNCTION:_default' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_railway__functions__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-functions-help-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(new)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(delete)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(push)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(pull)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(link)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(fn)
_arguments "${_arguments_options[@]}" : \
'-e+[Environment ID/name]:ENVIRONMENT:_default' \
'--environment=[Environment ID/name]:ENVIRONMENT:_default' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
":: :_railway__functions_commands" \
"*::: :->functions" \
&& ret=0

    case $state in
    (functions)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-functions-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(ls)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(new)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the function locally]:PATH:_files' \
'--path=[The path to the function locally]:PATH:_files' \
'-n+[The name of the function]:NAME:_default' \
'--name=[The name of the function]:NAME:_default' \
'-c+[Cron schedule to run the function]:CRON:_default' \
'--cron=[Cron schedule to run the function]:CRON:_default' \
'--http=[Generate a domain]' \
'-s+[Serverless (a.k.a sleeping)]' \
'--serverless=[Serverless (a.k.a sleeping)]' \
'-w+[Watch for changes of the file and deploy upon save]' \
'--watch=[Watch for changes of the file and deploy upon save]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(create)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the function locally]:PATH:_files' \
'--path=[The path to the function locally]:PATH:_files' \
'-n+[The name of the function]:NAME:_default' \
'--name=[The name of the function]:NAME:_default' \
'-c+[Cron schedule to run the function]:CRON:_default' \
'--cron=[Cron schedule to run the function]:CRON:_default' \
'--http=[Generate a domain]' \
'-s+[Serverless (a.k.a sleeping)]' \
'--serverless=[Serverless (a.k.a sleeping)]' \
'-w+[Watch for changes of the file and deploy upon save]' \
'--watch=[Watch for changes of the file and deploy upon save]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(delete)
_arguments "${_arguments_options[@]}" : \
'-f+[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'--function=[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'-y+[Skip confirmation for deleting]' \
'--yes=[Skip confirmation for deleting]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" : \
'-f+[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'--function=[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'-y+[Skip confirmation for deleting]' \
'--yes=[Skip confirmation for deleting]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(rm)
_arguments "${_arguments_options[@]}" : \
'-f+[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'--function=[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'-y+[Skip confirmation for deleting]' \
'--yes=[Skip confirmation for deleting]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(push)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the function]:PATH:_files' \
'--path=[The path to the function]:PATH:_files' \
'-w+[Watch for changes of the file and deploy upon save]' \
'--watch=[Watch for changes of the file and deploy upon save]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(up)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the function]:PATH:_files' \
'--path=[The path to the function]:PATH:_files' \
'-w+[Watch for changes of the file and deploy upon save]' \
'--watch=[Watch for changes of the file and deploy upon save]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(pull)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the function]:PATH:_files' \
'--path=[The path to the function]:PATH:_files' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(link)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the file]:PATH:_files' \
'--path=[The path to the file]:PATH:_files' \
'-f+[The ID/name of the function you wish to link to]:FUNCTION:_default' \
'--function=[The ID/name of the function you wish to link to]:FUNCTION:_default' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_railway__functions__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-functions-help-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(new)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(delete)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(push)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(pull)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(link)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(funcs)
_arguments "${_arguments_options[@]}" : \
'-e+[Environment ID/name]:ENVIRONMENT:_default' \
'--environment=[Environment ID/name]:ENVIRONMENT:_default' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
":: :_railway__functions_commands" \
"*::: :->functions" \
&& ret=0

    case $state in
    (functions)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-functions-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(ls)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(new)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the function locally]:PATH:_files' \
'--path=[The path to the function locally]:PATH:_files' \
'-n+[The name of the function]:NAME:_default' \
'--name=[The name of the function]:NAME:_default' \
'-c+[Cron schedule to run the function]:CRON:_default' \
'--cron=[Cron schedule to run the function]:CRON:_default' \
'--http=[Generate a domain]' \
'-s+[Serverless (a.k.a sleeping)]' \
'--serverless=[Serverless (a.k.a sleeping)]' \
'-w+[Watch for changes of the file and deploy upon save]' \
'--watch=[Watch for changes of the file and deploy upon save]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(create)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the function locally]:PATH:_files' \
'--path=[The path to the function locally]:PATH:_files' \
'-n+[The name of the function]:NAME:_default' \
'--name=[The name of the function]:NAME:_default' \
'-c+[Cron schedule to run the function]:CRON:_default' \
'--cron=[Cron schedule to run the function]:CRON:_default' \
'--http=[Generate a domain]' \
'-s+[Serverless (a.k.a sleeping)]' \
'--serverless=[Serverless (a.k.a sleeping)]' \
'-w+[Watch for changes of the file and deploy upon save]' \
'--watch=[Watch for changes of the file and deploy upon save]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(delete)
_arguments "${_arguments_options[@]}" : \
'-f+[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'--function=[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'-y+[Skip confirmation for deleting]' \
'--yes=[Skip confirmation for deleting]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" : \
'-f+[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'--function=[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'-y+[Skip confirmation for deleting]' \
'--yes=[Skip confirmation for deleting]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(rm)
_arguments "${_arguments_options[@]}" : \
'-f+[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'--function=[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'-y+[Skip confirmation for deleting]' \
'--yes=[Skip confirmation for deleting]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(push)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the function]:PATH:_files' \
'--path=[The path to the function]:PATH:_files' \
'-w+[Watch for changes of the file and deploy upon save]' \
'--watch=[Watch for changes of the file and deploy upon save]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(up)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the function]:PATH:_files' \
'--path=[The path to the function]:PATH:_files' \
'-w+[Watch for changes of the file and deploy upon save]' \
'--watch=[Watch for changes of the file and deploy upon save]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(pull)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the function]:PATH:_files' \
'--path=[The path to the function]:PATH:_files' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(link)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the file]:PATH:_files' \
'--path=[The path to the file]:PATH:_files' \
'-f+[The ID/name of the function you wish to link to]:FUNCTION:_default' \
'--function=[The ID/name of the function you wish to link to]:FUNCTION:_default' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_railway__functions__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-functions-help-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(new)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(delete)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(push)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(pull)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(link)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(fns)
_arguments "${_arguments_options[@]}" : \
'-e+[Environment ID/name]:ENVIRONMENT:_default' \
'--environment=[Environment ID/name]:ENVIRONMENT:_default' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
":: :_railway__functions_commands" \
"*::: :->functions" \
&& ret=0

    case $state in
    (functions)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-functions-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(ls)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(new)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the function locally]:PATH:_files' \
'--path=[The path to the function locally]:PATH:_files' \
'-n+[The name of the function]:NAME:_default' \
'--name=[The name of the function]:NAME:_default' \
'-c+[Cron schedule to run the function]:CRON:_default' \
'--cron=[Cron schedule to run the function]:CRON:_default' \
'--http=[Generate a domain]' \
'-s+[Serverless (a.k.a sleeping)]' \
'--serverless=[Serverless (a.k.a sleeping)]' \
'-w+[Watch for changes of the file and deploy upon save]' \
'--watch=[Watch for changes of the file and deploy upon save]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(create)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the function locally]:PATH:_files' \
'--path=[The path to the function locally]:PATH:_files' \
'-n+[The name of the function]:NAME:_default' \
'--name=[The name of the function]:NAME:_default' \
'-c+[Cron schedule to run the function]:CRON:_default' \
'--cron=[Cron schedule to run the function]:CRON:_default' \
'--http=[Generate a domain]' \
'-s+[Serverless (a.k.a sleeping)]' \
'--serverless=[Serverless (a.k.a sleeping)]' \
'-w+[Watch for changes of the file and deploy upon save]' \
'--watch=[Watch for changes of the file and deploy upon save]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(delete)
_arguments "${_arguments_options[@]}" : \
'-f+[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'--function=[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'-y+[Skip confirmation for deleting]' \
'--yes=[Skip confirmation for deleting]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(remove)
_arguments "${_arguments_options[@]}" : \
'-f+[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'--function=[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'-y+[Skip confirmation for deleting]' \
'--yes=[Skip confirmation for deleting]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(rm)
_arguments "${_arguments_options[@]}" : \
'-f+[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'--function=[The ID/name of the function you wish to delete]:FUNCTION:_default' \
'-y+[Skip confirmation for deleting]' \
'--yes=[Skip confirmation for deleting]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(push)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the function]:PATH:_files' \
'--path=[The path to the function]:PATH:_files' \
'-w+[Watch for changes of the file and deploy upon save]' \
'--watch=[Watch for changes of the file and deploy upon save]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(up)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the function]:PATH:_files' \
'--path=[The path to the function]:PATH:_files' \
'-w+[Watch for changes of the file and deploy upon save]' \
'--watch=[Watch for changes of the file and deploy upon save]' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(pull)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the function]:PATH:_files' \
'--path=[The path to the function]:PATH:_files' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(link)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the file]:PATH:_files' \
'--path=[The path to the file]:PATH:_files' \
'-f+[The ID/name of the function you wish to link to]:FUNCTION:_default' \
'--function=[The ID/name of the function you wish to link to]:FUNCTION:_default' \
'-h[Print help]' \
'--help[Print help]' \
'-V[Print version]' \
'--version[Print version]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_railway__functions__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-functions-help-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(new)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(delete)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(push)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(pull)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(link)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_railway__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-help-command-$line[1]:"
        case $line[1] in
            (add)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(completion)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(connect)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(deploy)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(deployment)
_arguments "${_arguments_options[@]}" : \
":: :_railway__help__deployment_commands" \
"*::: :->deployment" \
&& ret=0

    case $state in
    (deployment)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-help-deployment-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(up)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(redeploy)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(dev)
_arguments "${_arguments_options[@]}" : \
":: :_railway__help__dev_commands" \
"*::: :->dev" \
&& ret=0

    case $state in
    (dev)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-help-dev-command-$line[1]:"
        case $line[1] in
            (up)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(down)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(clean)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(configure)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(domain)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(docs)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(down)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(environment)
_arguments "${_arguments_options[@]}" : \
":: :_railway__help__environment_commands" \
"*::: :->environment" \
&& ret=0

    case $state in
    (environment)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-help-environment-command-$line[1]:"
        case $line[1] in
            (new)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(delete)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(init)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(link)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(login)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(logout)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(logs)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(open)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(run)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(service)
_arguments "${_arguments_options[@]}" : \
":: :_railway__help__service_commands" \
"*::: :->service" \
&& ret=0

    case $state in
    (service)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-help-service-command-$line[1]:"
        case $line[1] in
            (link)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(status)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(shell)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(ssh)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(starship)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(status)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(unlink)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(up)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(variables)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(whoami)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(volume)
_arguments "${_arguments_options[@]}" : \
":: :_railway__help__volume_commands" \
"*::: :->volume" \
&& ret=0

    case $state in
    (volume)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-help-volume-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(add)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(delete)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(update)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(detach)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(attach)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(redeploy)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(scale)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(check_updates)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(functions)
_arguments "${_arguments_options[@]}" : \
":: :_railway__help__functions_commands" \
"*::: :->functions" \
&& ret=0

    case $state in
    (functions)
        words=($line[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:railway-help-functions-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(new)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(delete)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(push)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(pull)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(link)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
}

(( $+functions[_railway_commands] )) ||
_railway_commands() {
    local commands; commands=(
'add:Add a service to your project' \
'completion:Generate completion script' \
'connect:Connect to a database'\''s shell (psql for Postgres, mongosh for MongoDB, etc.)' \
'deploy:Provisions a template into your project' \
'deployment:Manage deployments' \
'dev:Run Railway services locally' \
'develop:Run Railway services locally' \
'domain:Add a custom domain or generate a railway provided domain for a service' \
'docs:Open Railway Documentation in default browser' \
'down:Remove the most recent deployment' \
'environment:Create, delete or link an environment' \
'env:Create, delete or link an environment' \
'init:Create a new project' \
'link:Associate existing project with current directory, may specify projectId as an argument' \
'list:List all projects in your Railway account' \
'login:Login to your Railway account' \
'logout:Logout of your Railway account' \
'logs:View build or deploy logs from a Railway deployment' \
'open:Open your project dashboard' \
'run:Run a local command using variables from the active environment' \
'service:Manage services' \
'shell:Open a local subshell with Railway variables available' \
'ssh:Connect to a service via SSH' \
'starship:Starship Metadata' \
'status:Show information about the current project' \
'unlink:Disassociate project from current directory' \
'up:Upload and deploy project from the current directory' \
'variables:Show variables for active environment' \
'whoami:Get the current logged in user' \
'volume:Manage project volumes' \
'redeploy:Redeploy the latest deployment of a service' \
'scale:' \
'check_updates:Test the update check' \
'functions:Manage project functions' \
'function:Manage project functions' \
'func:Manage project functions' \
'fn:Manage project functions' \
'funcs:Manage project functions' \
'fns:Manage project functions' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'railway commands' commands "$@"
}
(( $+functions[_railway__add_commands] )) ||
_railway__add_commands() {
    local commands; commands=()
    _describe -t commands 'railway add commands' commands "$@"
}
(( $+functions[_railway__check_updates_commands] )) ||
_railway__check_updates_commands() {
    local commands; commands=()
    _describe -t commands 'railway check_updates commands' commands "$@"
}
(( $+functions[_railway__completion_commands] )) ||
_railway__completion_commands() {
    local commands; commands=()
    _describe -t commands 'railway completion commands' commands "$@"
}
(( $+functions[_railway__connect_commands] )) ||
_railway__connect_commands() {
    local commands; commands=()
    _describe -t commands 'railway connect commands' commands "$@"
}
(( $+functions[_railway__deploy_commands] )) ||
_railway__deploy_commands() {
    local commands; commands=()
    _describe -t commands 'railway deploy commands' commands "$@"
}
(( $+functions[_railway__deployment_commands] )) ||
_railway__deployment_commands() {
    local commands; commands=(
'list:List deployments for a service with IDs, statuses and other metadata' \
'up:Upload and deploy project from the current directory' \
'redeploy:Redeploy the latest deployment of a service' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'railway deployment commands' commands "$@"
}
(( $+functions[_railway__deployment__help_commands] )) ||
_railway__deployment__help_commands() {
    local commands; commands=(
'list:List deployments for a service with IDs, statuses and other metadata' \
'up:Upload and deploy project from the current directory' \
'redeploy:Redeploy the latest deployment of a service' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'railway deployment help commands' commands "$@"
}
(( $+functions[_railway__deployment__help__help_commands] )) ||
_railway__deployment__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'railway deployment help help commands' commands "$@"
}
(( $+functions[_railway__deployment__help__list_commands] )) ||
_railway__deployment__help__list_commands() {
    local commands; commands=()
    _describe -t commands 'railway deployment help list commands' commands "$@"
}
(( $+functions[_railway__deployment__help__redeploy_commands] )) ||
_railway__deployment__help__redeploy_commands() {
    local commands; commands=()
    _describe -t commands 'railway deployment help redeploy commands' commands "$@"
}
(( $+functions[_railway__deployment__help__up_commands] )) ||
_railway__deployment__help__up_commands() {
    local commands; commands=()
    _describe -t commands 'railway deployment help up commands' commands "$@"
}
(( $+functions[_railway__deployment__list_commands] )) ||
_railway__deployment__list_commands() {
    local commands; commands=()
    _describe -t commands 'railway deployment list commands' commands "$@"
}
(( $+functions[_railway__deployment__redeploy_commands] )) ||
_railway__deployment__redeploy_commands() {
    local commands; commands=()
    _describe -t commands 'railway deployment redeploy commands' commands "$@"
}
(( $+functions[_railway__deployment__up_commands] )) ||
_railway__deployment__up_commands() {
    local commands; commands=()
    _describe -t commands 'railway deployment up commands' commands "$@"
}
(( $+functions[_railway__dev_commands] )) ||
_railway__dev_commands() {
    local commands; commands=(
'up:Start services (default when no subcommand provided)' \
'down:Stop services' \
'clean:Stop services and remove volumes/data' \
'configure:Configure local code services' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'railway dev commands' commands "$@"
}
(( $+functions[_railway__dev__clean_commands] )) ||
_railway__dev__clean_commands() {
    local commands; commands=()
    _describe -t commands 'railway dev clean commands' commands "$@"
}
(( $+functions[_railway__dev__configure_commands] )) ||
_railway__dev__configure_commands() {
    local commands; commands=()
    _describe -t commands 'railway dev configure commands' commands "$@"
}
(( $+functions[_railway__dev__down_commands] )) ||
_railway__dev__down_commands() {
    local commands; commands=()
    _describe -t commands 'railway dev down commands' commands "$@"
}
(( $+functions[_railway__dev__help_commands] )) ||
_railway__dev__help_commands() {
    local commands; commands=(
'up:Start services (default when no subcommand provided)' \
'down:Stop services' \
'clean:Stop services and remove volumes/data' \
'configure:Configure local code services' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'railway dev help commands' commands "$@"
}
(( $+functions[_railway__dev__help__clean_commands] )) ||
_railway__dev__help__clean_commands() {
    local commands; commands=()
    _describe -t commands 'railway dev help clean commands' commands "$@"
}
(( $+functions[_railway__dev__help__configure_commands] )) ||
_railway__dev__help__configure_commands() {
    local commands; commands=()
    _describe -t commands 'railway dev help configure commands' commands "$@"
}
(( $+functions[_railway__dev__help__down_commands] )) ||
_railway__dev__help__down_commands() {
    local commands; commands=()
    _describe -t commands 'railway dev help down commands' commands "$@"
}
(( $+functions[_railway__dev__help__help_commands] )) ||
_railway__dev__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'railway dev help help commands' commands "$@"
}
(( $+functions[_railway__dev__help__up_commands] )) ||
_railway__dev__help__up_commands() {
    local commands; commands=()
    _describe -t commands 'railway dev help up commands' commands "$@"
}
(( $+functions[_railway__dev__up_commands] )) ||
_railway__dev__up_commands() {
    local commands; commands=()
    _describe -t commands 'railway dev up commands' commands "$@"
}
(( $+functions[_railway__docs_commands] )) ||
_railway__docs_commands() {
    local commands; commands=()
    _describe -t commands 'railway docs commands' commands "$@"
}
(( $+functions[_railway__domain_commands] )) ||
_railway__domain_commands() {
    local commands; commands=()
    _describe -t commands 'railway domain commands' commands "$@"
}
(( $+functions[_railway__down_commands] )) ||
_railway__down_commands() {
    local commands; commands=()
    _describe -t commands 'railway down commands' commands "$@"
}
(( $+functions[_railway__environment_commands] )) ||
_railway__environment_commands() {
    local commands; commands=(
'new:Create a new environment' \
'delete:Delete an environment' \
'remove:Delete an environment' \
'rm:Delete an environment' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'railway environment commands' commands "$@"
}
(( $+functions[_railway__environment__delete_commands] )) ||
_railway__environment__delete_commands() {
    local commands; commands=()
    _describe -t commands 'railway environment delete commands' commands "$@"
}
(( $+functions[_railway__environment__help_commands] )) ||
_railway__environment__help_commands() {
    local commands; commands=(
'new:Create a new environment' \
'delete:Delete an environment' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'railway environment help commands' commands "$@"
}
(( $+functions[_railway__environment__help__delete_commands] )) ||
_railway__environment__help__delete_commands() {
    local commands; commands=()
    _describe -t commands 'railway environment help delete commands' commands "$@"
}
(( $+functions[_railway__environment__help__help_commands] )) ||
_railway__environment__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'railway environment help help commands' commands "$@"
}
(( $+functions[_railway__environment__help__new_commands] )) ||
_railway__environment__help__new_commands() {
    local commands; commands=()
    _describe -t commands 'railway environment help new commands' commands "$@"
}
(( $+functions[_railway__environment__new_commands] )) ||
_railway__environment__new_commands() {
    local commands; commands=()
    _describe -t commands 'railway environment new commands' commands "$@"
}
(( $+functions[_railway__functions_commands] )) ||
_railway__functions_commands() {
    local commands; commands=(
'list:List functions' \
'ls:List functions' \
'new:Add a new function' \
'create:Add a new function' \
'delete:Delete a function' \
'remove:Delete a function' \
'rm:Delete a function' \
'push:Push a new change to the function' \
'up:Push a new change to the function' \
'pull:Pull changes from the linked function remotely' \
'link:Link a function manually' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'railway functions commands' commands "$@"
}
(( $+functions[_railway__functions__delete_commands] )) ||
_railway__functions__delete_commands() {
    local commands; commands=()
    _describe -t commands 'railway functions delete commands' commands "$@"
}
(( $+functions[_railway__functions__help_commands] )) ||
_railway__functions__help_commands() {
    local commands; commands=(
'list:List functions' \
'new:Add a new function' \
'delete:Delete a function' \
'push:Push a new change to the function' \
'pull:Pull changes from the linked function remotely' \
'link:Link a function manually' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'railway functions help commands' commands "$@"
}
(( $+functions[_railway__functions__help__delete_commands] )) ||
_railway__functions__help__delete_commands() {
    local commands; commands=()
    _describe -t commands 'railway functions help delete commands' commands "$@"
}
(( $+functions[_railway__functions__help__help_commands] )) ||
_railway__functions__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'railway functions help help commands' commands "$@"
}
(( $+functions[_railway__functions__help__link_commands] )) ||
_railway__functions__help__link_commands() {
    local commands; commands=()
    _describe -t commands 'railway functions help link commands' commands "$@"
}
(( $+functions[_railway__functions__help__list_commands] )) ||
_railway__functions__help__list_commands() {
    local commands; commands=()
    _describe -t commands 'railway functions help list commands' commands "$@"
}
(( $+functions[_railway__functions__help__new_commands] )) ||
_railway__functions__help__new_commands() {
    local commands; commands=()
    _describe -t commands 'railway functions help new commands' commands "$@"
}
(( $+functions[_railway__functions__help__pull_commands] )) ||
_railway__functions__help__pull_commands() {
    local commands; commands=()
    _describe -t commands 'railway functions help pull commands' commands "$@"
}
(( $+functions[_railway__functions__help__push_commands] )) ||
_railway__functions__help__push_commands() {
    local commands; commands=()
    _describe -t commands 'railway functions help push commands' commands "$@"
}
(( $+functions[_railway__functions__link_commands] )) ||
_railway__functions__link_commands() {
    local commands; commands=()
    _describe -t commands 'railway functions link commands' commands "$@"
}
(( $+functions[_railway__functions__list_commands] )) ||
_railway__functions__list_commands() {
    local commands; commands=()
    _describe -t commands 'railway functions list commands' commands "$@"
}
(( $+functions[_railway__functions__new_commands] )) ||
_railway__functions__new_commands() {
    local commands; commands=()
    _describe -t commands 'railway functions new commands' commands "$@"
}
(( $+functions[_railway__functions__pull_commands] )) ||
_railway__functions__pull_commands() {
    local commands; commands=()
    _describe -t commands 'railway functions pull commands' commands "$@"
}
(( $+functions[_railway__functions__push_commands] )) ||
_railway__functions__push_commands() {
    local commands; commands=()
    _describe -t commands 'railway functions push commands' commands "$@"
}
(( $+functions[_railway__help_commands] )) ||
_railway__help_commands() {
    local commands; commands=(
'add:Add a service to your project' \
'completion:Generate completion script' \
'connect:Connect to a database'\''s shell (psql for Postgres, mongosh for MongoDB, etc.)' \
'deploy:Provisions a template into your project' \
'deployment:Manage deployments' \
'dev:Run Railway services locally' \
'domain:Add a custom domain or generate a railway provided domain for a service' \
'docs:Open Railway Documentation in default browser' \
'down:Remove the most recent deployment' \
'environment:Create, delete or link an environment' \
'init:Create a new project' \
'link:Associate existing project with current directory, may specify projectId as an argument' \
'list:List all projects in your Railway account' \
'login:Login to your Railway account' \
'logout:Logout of your Railway account' \
'logs:View build or deploy logs from a Railway deployment' \
'open:Open your project dashboard' \
'run:Run a local command using variables from the active environment' \
'service:Manage services' \
'shell:Open a local subshell with Railway variables available' \
'ssh:Connect to a service via SSH' \
'starship:Starship Metadata' \
'status:Show information about the current project' \
'unlink:Disassociate project from current directory' \
'up:Upload and deploy project from the current directory' \
'variables:Show variables for active environment' \
'whoami:Get the current logged in user' \
'volume:Manage project volumes' \
'redeploy:Redeploy the latest deployment of a service' \
'scale:' \
'check_updates:Test the update check' \
'functions:Manage project functions' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'railway help commands' commands "$@"
}
(( $+functions[_railway__help__add_commands] )) ||
_railway__help__add_commands() {
    local commands; commands=()
    _describe -t commands 'railway help add commands' commands "$@"
}
(( $+functions[_railway__help__check_updates_commands] )) ||
_railway__help__check_updates_commands() {
    local commands; commands=()
    _describe -t commands 'railway help check_updates commands' commands "$@"
}
(( $+functions[_railway__help__completion_commands] )) ||
_railway__help__completion_commands() {
    local commands; commands=()
    _describe -t commands 'railway help completion commands' commands "$@"
}
(( $+functions[_railway__help__connect_commands] )) ||
_railway__help__connect_commands() {
    local commands; commands=()
    _describe -t commands 'railway help connect commands' commands "$@"
}
(( $+functions[_railway__help__deploy_commands] )) ||
_railway__help__deploy_commands() {
    local commands; commands=()
    _describe -t commands 'railway help deploy commands' commands "$@"
}
(( $+functions[_railway__help__deployment_commands] )) ||
_railway__help__deployment_commands() {
    local commands; commands=(
'list:List deployments for a service with IDs, statuses and other metadata' \
'up:Upload and deploy project from the current directory' \
'redeploy:Redeploy the latest deployment of a service' \
    )
    _describe -t commands 'railway help deployment commands' commands "$@"
}
(( $+functions[_railway__help__deployment__list_commands] )) ||
_railway__help__deployment__list_commands() {
    local commands; commands=()
    _describe -t commands 'railway help deployment list commands' commands "$@"
}
(( $+functions[_railway__help__deployment__redeploy_commands] )) ||
_railway__help__deployment__redeploy_commands() {
    local commands; commands=()
    _describe -t commands 'railway help deployment redeploy commands' commands "$@"
}
(( $+functions[_railway__help__deployment__up_commands] )) ||
_railway__help__deployment__up_commands() {
    local commands; commands=()
    _describe -t commands 'railway help deployment up commands' commands "$@"
}
(( $+functions[_railway__help__dev_commands] )) ||
_railway__help__dev_commands() {
    local commands; commands=(
'up:Start services (default when no subcommand provided)' \
'down:Stop services' \
'clean:Stop services and remove volumes/data' \
'configure:Configure local code services' \
    )
    _describe -t commands 'railway help dev commands' commands "$@"
}
(( $+functions[_railway__help__dev__clean_commands] )) ||
_railway__help__dev__clean_commands() {
    local commands; commands=()
    _describe -t commands 'railway help dev clean commands' commands "$@"
}
(( $+functions[_railway__help__dev__configure_commands] )) ||
_railway__help__dev__configure_commands() {
    local commands; commands=()
    _describe -t commands 'railway help dev configure commands' commands "$@"
}
(( $+functions[_railway__help__dev__down_commands] )) ||
_railway__help__dev__down_commands() {
    local commands; commands=()
    _describe -t commands 'railway help dev down commands' commands "$@"
}
(( $+functions[_railway__help__dev__up_commands] )) ||
_railway__help__dev__up_commands() {
    local commands; commands=()
    _describe -t commands 'railway help dev up commands' commands "$@"
}
(( $+functions[_railway__help__docs_commands] )) ||
_railway__help__docs_commands() {
    local commands; commands=()
    _describe -t commands 'railway help docs commands' commands "$@"
}
(( $+functions[_railway__help__domain_commands] )) ||
_railway__help__domain_commands() {
    local commands; commands=()
    _describe -t commands 'railway help domain commands' commands "$@"
}
(( $+functions[_railway__help__down_commands] )) ||
_railway__help__down_commands() {
    local commands; commands=()
    _describe -t commands 'railway help down commands' commands "$@"
}
(( $+functions[_railway__help__environment_commands] )) ||
_railway__help__environment_commands() {
    local commands; commands=(
'new:Create a new environment' \
'delete:Delete an environment' \
    )
    _describe -t commands 'railway help environment commands' commands "$@"
}
(( $+functions[_railway__help__environment__delete_commands] )) ||
_railway__help__environment__delete_commands() {
    local commands; commands=()
    _describe -t commands 'railway help environment delete commands' commands "$@"
}
(( $+functions[_railway__help__environment__new_commands] )) ||
_railway__help__environment__new_commands() {
    local commands; commands=()
    _describe -t commands 'railway help environment new commands' commands "$@"
}
(( $+functions[_railway__help__functions_commands] )) ||
_railway__help__functions_commands() {
    local commands; commands=(
'list:List functions' \
'new:Add a new function' \
'delete:Delete a function' \
'push:Push a new change to the function' \
'pull:Pull changes from the linked function remotely' \
'link:Link a function manually' \
    )
    _describe -t commands 'railway help functions commands' commands "$@"
}
(( $+functions[_railway__help__functions__delete_commands] )) ||
_railway__help__functions__delete_commands() {
    local commands; commands=()
    _describe -t commands 'railway help functions delete commands' commands "$@"
}
(( $+functions[_railway__help__functions__link_commands] )) ||
_railway__help__functions__link_commands() {
    local commands; commands=()
    _describe -t commands 'railway help functions link commands' commands "$@"
}
(( $+functions[_railway__help__functions__list_commands] )) ||
_railway__help__functions__list_commands() {
    local commands; commands=()
    _describe -t commands 'railway help functions list commands' commands "$@"
}
(( $+functions[_railway__help__functions__new_commands] )) ||
_railway__help__functions__new_commands() {
    local commands; commands=()
    _describe -t commands 'railway help functions new commands' commands "$@"
}
(( $+functions[_railway__help__functions__pull_commands] )) ||
_railway__help__functions__pull_commands() {
    local commands; commands=()
    _describe -t commands 'railway help functions pull commands' commands "$@"
}
(( $+functions[_railway__help__functions__push_commands] )) ||
_railway__help__functions__push_commands() {
    local commands; commands=()
    _describe -t commands 'railway help functions push commands' commands "$@"
}
(( $+functions[_railway__help__help_commands] )) ||
_railway__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'railway help help commands' commands "$@"
}
(( $+functions[_railway__help__init_commands] )) ||
_railway__help__init_commands() {
    local commands; commands=()
    _describe -t commands 'railway help init commands' commands "$@"
}
(( $+functions[_railway__help__link_commands] )) ||
_railway__help__link_commands() {
    local commands; commands=()
    _describe -t commands 'railway help link commands' commands "$@"
}
(( $+functions[_railway__help__list_commands] )) ||
_railway__help__list_commands() {
    local commands; commands=()
    _describe -t commands 'railway help list commands' commands "$@"
}
(( $+functions[_railway__help__login_commands] )) ||
_railway__help__login_commands() {
    local commands; commands=()
    _describe -t commands 'railway help login commands' commands "$@"
}
(( $+functions[_railway__help__logout_commands] )) ||
_railway__help__logout_commands() {
    local commands; commands=()
    _describe -t commands 'railway help logout commands' commands "$@"
}
(( $+functions[_railway__help__logs_commands] )) ||
_railway__help__logs_commands() {
    local commands; commands=()
    _describe -t commands 'railway help logs commands' commands "$@"
}
(( $+functions[_railway__help__open_commands] )) ||
_railway__help__open_commands() {
    local commands; commands=()
    _describe -t commands 'railway help open commands' commands "$@"
}
(( $+functions[_railway__help__redeploy_commands] )) ||
_railway__help__redeploy_commands() {
    local commands; commands=()
    _describe -t commands 'railway help redeploy commands' commands "$@"
}
(( $+functions[_railway__help__run_commands] )) ||
_railway__help__run_commands() {
    local commands; commands=()
    _describe -t commands 'railway help run commands' commands "$@"
}
(( $+functions[_railway__help__scale_commands] )) ||
_railway__help__scale_commands() {
    local commands; commands=()
    _describe -t commands 'railway help scale commands' commands "$@"
}
(( $+functions[_railway__help__service_commands] )) ||
_railway__help__service_commands() {
    local commands; commands=(
'link:Link a service to the current project' \
'status:Show deployment status for services' \
    )
    _describe -t commands 'railway help service commands' commands "$@"
}
(( $+functions[_railway__help__service__link_commands] )) ||
_railway__help__service__link_commands() {
    local commands; commands=()
    _describe -t commands 'railway help service link commands' commands "$@"
}
(( $+functions[_railway__help__service__status_commands] )) ||
_railway__help__service__status_commands() {
    local commands; commands=()
    _describe -t commands 'railway help service status commands' commands "$@"
}
(( $+functions[_railway__help__shell_commands] )) ||
_railway__help__shell_commands() {
    local commands; commands=()
    _describe -t commands 'railway help shell commands' commands "$@"
}
(( $+functions[_railway__help__ssh_commands] )) ||
_railway__help__ssh_commands() {
    local commands; commands=()
    _describe -t commands 'railway help ssh commands' commands "$@"
}
(( $+functions[_railway__help__starship_commands] )) ||
_railway__help__starship_commands() {
    local commands; commands=()
    _describe -t commands 'railway help starship commands' commands "$@"
}
(( $+functions[_railway__help__status_commands] )) ||
_railway__help__status_commands() {
    local commands; commands=()
    _describe -t commands 'railway help status commands' commands "$@"
}
(( $+functions[_railway__help__unlink_commands] )) ||
_railway__help__unlink_commands() {
    local commands; commands=()
    _describe -t commands 'railway help unlink commands' commands "$@"
}
(( $+functions[_railway__help__up_commands] )) ||
_railway__help__up_commands() {
    local commands; commands=()
    _describe -t commands 'railway help up commands' commands "$@"
}
(( $+functions[_railway__help__variables_commands] )) ||
_railway__help__variables_commands() {
    local commands; commands=()
    _describe -t commands 'railway help variables commands' commands "$@"
}
(( $+functions[_railway__help__volume_commands] )) ||
_railway__help__volume_commands() {
    local commands; commands=(
'list:List volumes' \
'add:Add a new volume' \
'delete:Delete a volume' \
'update:Update a volume' \
'detach:Detach a volume from a service' \
'attach:Attach a volume to a service' \
    )
    _describe -t commands 'railway help volume commands' commands "$@"
}
(( $+functions[_railway__help__volume__add_commands] )) ||
_railway__help__volume__add_commands() {
    local commands; commands=()
    _describe -t commands 'railway help volume add commands' commands "$@"
}
(( $+functions[_railway__help__volume__attach_commands] )) ||
_railway__help__volume__attach_commands() {
    local commands; commands=()
    _describe -t commands 'railway help volume attach commands' commands "$@"
}
(( $+functions[_railway__help__volume__delete_commands] )) ||
_railway__help__volume__delete_commands() {
    local commands; commands=()
    _describe -t commands 'railway help volume delete commands' commands "$@"
}
(( $+functions[_railway__help__volume__detach_commands] )) ||
_railway__help__volume__detach_commands() {
    local commands; commands=()
    _describe -t commands 'railway help volume detach commands' commands "$@"
}
(( $+functions[_railway__help__volume__list_commands] )) ||
_railway__help__volume__list_commands() {
    local commands; commands=()
    _describe -t commands 'railway help volume list commands' commands "$@"
}
(( $+functions[_railway__help__volume__update_commands] )) ||
_railway__help__volume__update_commands() {
    local commands; commands=()
    _describe -t commands 'railway help volume update commands' commands "$@"
}
(( $+functions[_railway__help__whoami_commands] )) ||
_railway__help__whoami_commands() {
    local commands; commands=()
    _describe -t commands 'railway help whoami commands' commands "$@"
}
(( $+functions[_railway__init_commands] )) ||
_railway__init_commands() {
    local commands; commands=()
    _describe -t commands 'railway init commands' commands "$@"
}
(( $+functions[_railway__link_commands] )) ||
_railway__link_commands() {
    local commands; commands=()
    _describe -t commands 'railway link commands' commands "$@"
}
(( $+functions[_railway__list_commands] )) ||
_railway__list_commands() {
    local commands; commands=()
    _describe -t commands 'railway list commands' commands "$@"
}
(( $+functions[_railway__login_commands] )) ||
_railway__login_commands() {
    local commands; commands=()
    _describe -t commands 'railway login commands' commands "$@"
}
(( $+functions[_railway__logout_commands] )) ||
_railway__logout_commands() {
    local commands; commands=()
    _describe -t commands 'railway logout commands' commands "$@"
}
(( $+functions[_railway__logs_commands] )) ||
_railway__logs_commands() {
    local commands; commands=()
    _describe -t commands 'railway logs commands' commands "$@"
}
(( $+functions[_railway__open_commands] )) ||
_railway__open_commands() {
    local commands; commands=()
    _describe -t commands 'railway open commands' commands "$@"
}
(( $+functions[_railway__redeploy_commands] )) ||
_railway__redeploy_commands() {
    local commands; commands=()
    _describe -t commands 'railway redeploy commands' commands "$@"
}
(( $+functions[_railway__run_commands] )) ||
_railway__run_commands() {
    local commands; commands=()
    _describe -t commands 'railway run commands' commands "$@"
}
(( $+functions[_railway__scale_commands] )) ||
_railway__scale_commands() {
    local commands; commands=()
    _describe -t commands 'railway scale commands' commands "$@"
}
(( $+functions[_railway__service_commands] )) ||
_railway__service_commands() {
    local commands; commands=(
'link:Link a service to the current project' \
'status:Show deployment status for services' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'railway service commands' commands "$@"
}
(( $+functions[_railway__service__help_commands] )) ||
_railway__service__help_commands() {
    local commands; commands=(
'link:Link a service to the current project' \
'status:Show deployment status for services' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'railway service help commands' commands "$@"
}
(( $+functions[_railway__service__help__help_commands] )) ||
_railway__service__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'railway service help help commands' commands "$@"
}
(( $+functions[_railway__service__help__link_commands] )) ||
_railway__service__help__link_commands() {
    local commands; commands=()
    _describe -t commands 'railway service help link commands' commands "$@"
}
(( $+functions[_railway__service__help__status_commands] )) ||
_railway__service__help__status_commands() {
    local commands; commands=()
    _describe -t commands 'railway service help status commands' commands "$@"
}
(( $+functions[_railway__service__link_commands] )) ||
_railway__service__link_commands() {
    local commands; commands=()
    _describe -t commands 'railway service link commands' commands "$@"
}
(( $+functions[_railway__service__status_commands] )) ||
_railway__service__status_commands() {
    local commands; commands=()
    _describe -t commands 'railway service status commands' commands "$@"
}
(( $+functions[_railway__shell_commands] )) ||
_railway__shell_commands() {
    local commands; commands=()
    _describe -t commands 'railway shell commands' commands "$@"
}
(( $+functions[_railway__ssh_commands] )) ||
_railway__ssh_commands() {
    local commands; commands=()
    _describe -t commands 'railway ssh commands' commands "$@"
}
(( $+functions[_railway__starship_commands] )) ||
_railway__starship_commands() {
    local commands; commands=()
    _describe -t commands 'railway starship commands' commands "$@"
}
(( $+functions[_railway__status_commands] )) ||
_railway__status_commands() {
    local commands; commands=()
    _describe -t commands 'railway status commands' commands "$@"
}
(( $+functions[_railway__unlink_commands] )) ||
_railway__unlink_commands() {
    local commands; commands=()
    _describe -t commands 'railway unlink commands' commands "$@"
}
(( $+functions[_railway__up_commands] )) ||
_railway__up_commands() {
    local commands; commands=()
    _describe -t commands 'railway up commands' commands "$@"
}
(( $+functions[_railway__variables_commands] )) ||
_railway__variables_commands() {
    local commands; commands=()
    _describe -t commands 'railway variables commands' commands "$@"
}
(( $+functions[_railway__volume_commands] )) ||
_railway__volume_commands() {
    local commands; commands=(
'list:List volumes' \
'add:Add a new volume' \
'delete:Delete a volume' \
'update:Update a volume' \
'detach:Detach a volume from a service' \
'attach:Attach a volume to a service' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'railway volume commands' commands "$@"
}
(( $+functions[_railway__volume__add_commands] )) ||
_railway__volume__add_commands() {
    local commands; commands=()
    _describe -t commands 'railway volume add commands' commands "$@"
}
(( $+functions[_railway__volume__attach_commands] )) ||
_railway__volume__attach_commands() {
    local commands; commands=()
    _describe -t commands 'railway volume attach commands' commands "$@"
}
(( $+functions[_railway__volume__delete_commands] )) ||
_railway__volume__delete_commands() {
    local commands; commands=()
    _describe -t commands 'railway volume delete commands' commands "$@"
}
(( $+functions[_railway__volume__detach_commands] )) ||
_railway__volume__detach_commands() {
    local commands; commands=()
    _describe -t commands 'railway volume detach commands' commands "$@"
}
(( $+functions[_railway__volume__help_commands] )) ||
_railway__volume__help_commands() {
    local commands; commands=(
'list:List volumes' \
'add:Add a new volume' \
'delete:Delete a volume' \
'update:Update a volume' \
'detach:Detach a volume from a service' \
'attach:Attach a volume to a service' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'railway volume help commands' commands "$@"
}
(( $+functions[_railway__volume__help__add_commands] )) ||
_railway__volume__help__add_commands() {
    local commands; commands=()
    _describe -t commands 'railway volume help add commands' commands "$@"
}
(( $+functions[_railway__volume__help__attach_commands] )) ||
_railway__volume__help__attach_commands() {
    local commands; commands=()
    _describe -t commands 'railway volume help attach commands' commands "$@"
}
(( $+functions[_railway__volume__help__delete_commands] )) ||
_railway__volume__help__delete_commands() {
    local commands; commands=()
    _describe -t commands 'railway volume help delete commands' commands "$@"
}
(( $+functions[_railway__volume__help__detach_commands] )) ||
_railway__volume__help__detach_commands() {
    local commands; commands=()
    _describe -t commands 'railway volume help detach commands' commands "$@"
}
(( $+functions[_railway__volume__help__help_commands] )) ||
_railway__volume__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'railway volume help help commands' commands "$@"
}
(( $+functions[_railway__volume__help__list_commands] )) ||
_railway__volume__help__list_commands() {
    local commands; commands=()
    _describe -t commands 'railway volume help list commands' commands "$@"
}
(( $+functions[_railway__volume__help__update_commands] )) ||
_railway__volume__help__update_commands() {
    local commands; commands=()
    _describe -t commands 'railway volume help update commands' commands "$@"
}
(( $+functions[_railway__volume__list_commands] )) ||
_railway__volume__list_commands() {
    local commands; commands=()
    _describe -t commands 'railway volume list commands' commands "$@"
}
(( $+functions[_railway__volume__update_commands] )) ||
_railway__volume__update_commands() {
    local commands; commands=()
    _describe -t commands 'railway volume update commands' commands "$@"
}
(( $+functions[_railway__whoami_commands] )) ||
_railway__whoami_commands() {
    local commands; commands=()
    _describe -t commands 'railway whoami commands' commands "$@"
}

if [ "$funcstack[1]" = "_railway" ]; then
    _railway "$@"
else
    compdef _railway railway
fi
