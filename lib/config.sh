# config.sh - git-based configuration management

# Get a config value (merged from all sources)
cfg_get() {
  local key="$1"
  git config --get "$key" 2>/dev/null || true
}

# Get all values for a multi-valued config
cfg_get_all() {
  local key="$1"
  local file_key="${2:-}"
  local scope="${3:-auto}"

  local args=()
  [ "$scope" != "auto" ] && args+=("--$scope")

  # 1. Check git config
  local result
  result=$(git config "${args[@]}" --get-all "$key" 2>/dev/null || true)

  # 2. Check local file-based config if provided (.wtrconfig)
  if [ -n "$file_key" ] && [ -f ".wtrconfig" ]; then
    # Simple parser for key=value
    local file_result
    file_result=$(grep "^$file_key=" ".wtrconfig" | cut -d'=' -f2- || true)
    if [ -n "$file_result" ]; then
      if [ -n "$result" ]; then
        result="$result"$'\n'"$file_result"
      else
        result="$file_result"
      fi
    fi
  fi

  echo "$result"
}

# Get config with a default value and environment override
cfg_default() {
  local key="$1"
  local env_var="$2"
  local default_val="$3"
  local file_key="${4:-}"

  # 1. Environment variable
  if [ -n "${!env_var:-}" ]; then
    echo "${!env_var}"
    return 0
  fi

  # 2. Git config or file-based config
  local val
  val=$(cfg_get_all "$key" "$file_key" | tail -n 1)
  if [ -n "$val" ]; then
    echo "$val"
    return 0
  fi

  # 3. Default
  echo "$default_val"
}

# Set a config value
cfg_set() {
  local key="$1"
  local value="$2"
  local scope="${3:-local}"
  git config "--$scope" "$key" "$value"
}

# Add to a multi-valued config
cfg_add() {
  local key="$1"
  local value="$2"
  local scope="${3:-local}"
  git config "--$scope" --add "$key" "$value"
}

# Unset a config value
cfg_unset() {
  local key="$1"
  local scope="${2:-local}"
  git config "--$scope" --unset-all "$key" 2>/dev/null || true
}

# List all wtr.* config values
cfg_list() {
  local scope="${1:-auto}"
  local args=()
  [ "$scope" != "auto" ] && args+=("--$scope")

  git config "${args[@]}" --list | grep "^wtr\." || true

  # Also show .wtrconfig if exists and not restricted by scope
  if [ "$scope" = "auto" ] || [ "$scope" = "local" ]; then
    if [ -f ".wtrconfig" ]; then
      echo "--- from .wtrconfig ---"
      cat ".wtrconfig"
    fi
  fi
}
