# =============================================================================
# SSH Manager (sshm) - Shell Integration (Zsh & Bash)
# =============================================================================

# Transparent SSH function wrapper
ssh() {
    # 1. No arguments: launch interactive server picker
    if [ $# -eq 0 ]; then
        if command -v sshm >/dev/null 2>&1; then
            sshm connect
            return $?
        else
            command ssh
            return $?
        fi
    fi

    # 2. Subcommands dedicated to SSH Manager
    case "$1" in
        list|ls)
            shift
            sshm list "$@"
            return $?
            ;;
        connect|conn|c)
            shift
            sshm connect "$@"
            return $?
            ;;
        set|add)
            shift
            sshm set "$@"
            return $?
            ;;
        rm|delete|del|remove)
            shift
            sshm rm "$@"
            return $?
            ;;
        edit)
            shift
            sshm edit "$@"
            return $?
            ;;
        test|ping)
            shift
            sshm test "$@"
            return $?
            ;;
        copy-id)
            shift
            sshm copy-id "$@"
            return $?
            ;;
        sync)
            shift
            sshm sync "$@"
            return $?
            ;;
    esac

    # 3. Direct server alias: e.g. 'ssh myserver' connects directly with stats update
    if [ $# -eq 1 ] && [ "${1#-}" = "$1" ] && command -v sshm >/dev/null 2>&1; then
        if sshm _is_server "$1" >/dev/null 2>&1; then
            sshm connect "$1"
            return $?
        fi
    fi

    # 4. Standard OpenSSH fallback: transparent execution
    command ssh "$@"
}

# Smart completions for ZSH
if [ -n "$ZSH_VERSION" ]; then
    _sshm_zsh_completion() {
        local -a subcmds
        subcmds=(
            'list:Lister tous les serveurs SSH et tester leur latence'
            'connect:Se connecter à un serveur (menu interactif si omis)'
            'set:Ajouter ou modifier un serveur SSH'
            'rm:Supprimer un serveur enregistré'
            'edit:Modifier interactivement les paramètres d'\''un serveur'
            'test:Tester la connectivité TCP et la clé d'\''un serveur'
            'copy-id:Copier votre clé publique sur le serveur'
            'sync:Synchroniser la configuration OpenSSH ~/.ssh/sshm_config'
        )

        if (( CURRENT == 2 )); then
            _describe -t commands 'commandes sshm' subcmds
            if command -v sshm >/dev/null 2>&1; then
                local -a srvs
                srvs=(${(f)"$(sshm _complete_names 2>/dev/null)"})
                if [ ${#srvs[@]} -gt 0 ]; then
                    _describe -t servers 'serveurs enregistrés' srvs
                fi
            fi
        elif (( CURRENT == 3 )); then
            case "$words[2]" in
                connect|c|conn|edit|rm|delete|del|test|ping|copy-id)
                    if command -v sshm >/dev/null 2>&1; then
                        local -a srvs
                        srvs=(${(f)"$(sshm _complete_names 2>/dev/null)"})
                        if [ ${#srvs[@]} -gt 0 ]; then
                            _describe -t servers 'serveurs enregistrés' srvs
                        fi
                    fi
                    ;;
            esac
        fi
    }
    compdef _sshm_zsh_completion sshm
fi

# Smart completions for Bash
if [ -n "$BASH_VERSION" ]; then
    _sshm_bash_completion() {
        local cur prev words cword
        _init_completion || return

        local subcmds="list ls connect c set add rm delete edit test ping copy-id sync"
        if [ $cword -eq 1 ]; then
            local servers=""
            if command -v sshm >/dev/null 2>&1; then
                servers=$(sshm _complete_names 2>/dev/null)
            fi
            COMPREPLY=($(compgen -W "$subcmds $servers" -- "$cur"))
        elif [ $cword -eq 2 ]; then
            case "$prev" in
                connect|c|conn|edit|rm|delete|test|ping|copy-id)
                    if command -v sshm >/dev/null 2>&1; then
                        local servers=$(sshm _complete_names 2>/dev/null)
                        COMPREPLY=($(compgen -W "$servers" -- "$cur"))
                    fi
                    ;;
            esac
        fi
    }
    complete -F _sshm_bash_completion sshm
fi
