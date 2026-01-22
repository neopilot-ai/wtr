# bash completion for wtr
_wtr() {
  local cur prev opts
  COMPREPLY=()
  _get_comp_words_by_ref -n : cur prev 2>/dev/null || return 0
  
  # Available commands
  local cmds="create new remove rm go run editor ai copy ls list dashboard status ui hooks sync exec backup restore clean doctor adapter adapters config help version"
  
  # Available shells
  local shells="bash zsh fish"

  # Helper to get available adapters
  _get_adapters() {
    local type="$1"
    local adapters_dir
    adapters_dir="$(dirname "${BASH_SOURCE[0]}")/../adapters/$type"
    if [ -d "$adapters_dir" ]; then
      find "$adapters_dir" -maxdepth 1 -name "*.sh" | sed "s|.*/||;s/\.sh$//" | tr '\n' ' '
    fi
  }

  local editors="vscode vscode_remote nvim vim emacs cursor zed idea webstorm pycharm atom sublime nano"
  local ai_tools="aider claude continue codex copilot gemini cursor opencode"
  
  if [[ ${#COMP_WORDS[@]} -eq 2 ]]; then
    # First argument - complete with commands
    COMPREPLY=($(compgen -W "$cmds" -- "$cur"))
  else
    case "${COMP_WORDS[1]}" in
      create|new|editor|ai)
        if [[ $prev == --editor ]]; then
          COMPREPLY=($(compgen -W "$editors" -- "$cur"))
        elif [[ $prev == --ai ]]; then
          COMPREPLY=($(compgen -W "$ai_tools" -- "$cur"))
        elif [[ $prev == --track ]]; then
          COMPREPLY=($(compgen -W "auto true false" -- "$cur"))
        elif [[ $prev == --preset ]]; then
          # Potentially complete with presets from config
          COMPREPLY=($(compgen -W "default" -- "$cur"))
        else
          # Complete flags
          local flags="--from --from-current --track --no-copy --no-fetch --yes --force --name --editor -e --ai -a --preset"
          COMPREPLY=($(compgen -W "$flags" -- "$cur"))
        fi
        ;;
      remove|rm|go|run|ls|list|status|dashboard|ui|hooks|sync|exec|backup|restore|clean)
        # Complete with branch names
        local branches=$(git branch --format='%(refname:short)' 2>/dev/null)
        COMPREPLY=($(compgen -W "$branches" -- "$cur"))
        ;;
      completions)
        COMPREPLY=($(compgen -W "$shells" -- "$cur"))
        ;;
      config)
        local config_cmds="get set list unset"
        COMPREPLY=($(compgen -W "$config_cmds" -- "$cur"))
        ;;
    esac
  fi
  
  __ltrim_colon_completions "$cur" 2>/dev/null || true
}

complete -F _wtr wtr
