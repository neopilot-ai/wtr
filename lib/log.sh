# Colors
BOLD="\033[1m"
DIM="\033[2m"
ITALIC="\033[3m"
RESET="\033[0m"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
GRAY="\033[0;90m"

# Logging functions with file support
_log_to_file() {
  if [ -n "${WTR_LOG_FILE:-}" ]; then
    local level="$1"
    shift
    local msg
    # Strip ANSI colors for file logging
    msg=$(echo "$*" | sed 's/\x1b\[[0-9;]*m//g')
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $msg" >> "$WTR_LOG_FILE"
  fi
}

log_info() { echo -e "${BLUE}[info]${RESET} $*" >&2; _log_to_file "INFO" "$*"; }
log_success() { echo -e "${GREEN}[ok]${RESET} $*" >&2; _log_to_file "SUCCESS" "$*"; }
log_error() { echo -e "${RED}[error]${RESET} $*" >&2; _log_to_file "ERROR" "$*"; }
log_warn() { echo -e "${YELLOW}[warn]${RESET} $*" >&2; _log_to_file "WARN" "$*"; }
log_step() { echo -e "${CYAN}==>${RESET} $*" >&2; _log_to_file "STEP" "$*"; }
log_debug() { 
  if [ "${WTR_DEBUG:-}" = "1" ] || [ "${NEOPILOT_DEBUG:-}" = "1" ]; then
    echo -e "${GRAY}[debug]${RESET} $*" >&2
    _log_to_file "DEBUG" "$*"
  fi
}

# Legacy aliases
info() { log_info "$@"; }
success() { log_success "$@"; }
debug() { log_debug "$@"; }
