#!/usr/bin/env bash
# install.sh - Install git-wtr (Git Worktree Runner)
#
# This script installs git-wtr by creating a symlink in an appropriate
# location based on your platform and available tools.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GIT_WTR_PATH="$SCRIPT_DIR/bin/git-wtr"

log_info() {
  echo -e "${BLUE}==>${NC} $1"
}

log_success() {
  echo -e "${GREEN}==>${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}Warning:${NC} $1"
}

log_error() {
  echo -e "${RED}Error:${NC} $1"
}

# Check if a directory is in PATH
in_path() {
  echo "$PATH" | tr ':' '\n' | grep -Fqx "$1"
}

# Windows-specific installation guidance
# Symlinks and sudo don't work reliably in Git Bash/MSYS/Cygwin
install_windows() {
  local bin_dir="$SCRIPT_DIR/bin"

  log_warn "Automatic symlink creation is not supported on Windows Git Bash."
  echo
  log_info "Windows installation options:"
  echo
  echo "  Option 1: Add git-wtr's bin directory to your PATH"
  echo "  ─────────────────────────────────────────────────────"
  echo "  Add this line to your ~/.bashrc or ~/.bash_profile:"
  echo
  echo "    export PATH=\"$bin_dir:\$PATH\""
  echo
  echo "  Then restart your terminal or run: source ~/.bashrc"
  echo
  echo "  Option 2: Create a symlink manually (requires admin)"
  echo "  ─────────────────────────────────────────────────────"
  echo "  Open an Administrator Command Prompt and run:"
  echo
  echo "    mklink \"C:\\Program Files\\Git\\usr\\bin\\git-wtr\" \"$(cygpath -w "$GIT_WTR_PATH" 2>/dev/null || echo "$GIT_WTR_PATH")\""
  echo
  echo "  Option 3: Copy the script directly"
  echo "  ─────────────────────────────────────────────────────"
  echo "  Copy git-wtr to your local bin directory:"
  echo
  echo "    mkdir -p ~/bin && cp \"$GIT_WTR_PATH\" ~/bin/git-wtr"
  echo

  # Check if bin_dir is already in PATH
  if in_path "$bin_dir"; then
    log_success "Good news: $bin_dir is already in your PATH!"
    verify_installation
  else
    echo
    log_info "After completing one of the options above, verify with:"
    echo "    git wtr version"
  fi
}

# Detect platform
detect_platform() {
  case "$(uname -s)" in
    Darwin)
      echo "macos"
      ;;
    Linux)
      echo "linux"
      ;;
    MINGW*|MSYS*|CYGWIN*)
      echo "windows"
      ;;
    *)
      echo "unknown"
      ;;
  esac
}

# Find the best installation directory
find_install_dir() {
  # Option 1: Homebrew bin (if Homebrew is installed)
  if command -v brew >/dev/null 2>&1; then
    local brew_bin
    brew_bin="$(brew --prefix)/bin"
    if [ -d "$brew_bin" ] && [ -w "$brew_bin" ]; then
      echo "$brew_bin"
      return 0
    fi
  fi

  # Option 2: /usr/local/bin (if it exists and is in PATH)
  if [ -d "/usr/local/bin" ] && in_path "/usr/local/bin"; then
    echo "/usr/local/bin"
    return 0
  fi

  # Option 3: ~/.local/bin (if it exists)
  if [ -d "$HOME/.local/bin" ]; then
    echo "$HOME/.local/bin"
    return 0
  fi

  # Option 4: ~/bin (user-local, create if needed)
  echo "$HOME/bin"
  return 0
}

# Check if we need sudo for a directory
needs_sudo() {
  local dir="$1"
  [ ! -w "$dir" ] && [ -d "$dir" ]
}

# Main installation
main() {
  log_info "Installing git-wtr (Git Worktree Runner)..."
  echo

  # Verify git-wtr exists
  if [ ! -f "$GIT_WTR_PATH" ]; then
    log_error "Could not find git-wtr at: $GIT_WTR_PATH"
    log_error "Please run this script from the wtr directory."
    exit 1
  fi

  # Ensure git-wtr is executable (auto-fix if needed)
  if [ ! -x "$GIT_WTR_PATH" ]; then
    log_warn "git-wtr is not executable, fixing permissions..."
    chmod +x "$GIT_WTR_PATH"
  fi

  # Detect platform
  local platform
  platform="$(detect_platform)"
  log_info "Detected platform: $platform"

  # Windows requires manual installation (symlinks/sudo don't work in Git Bash)
  if [ "$platform" = "windows" ]; then
    install_windows
    exit 0
  fi

  # Find installation directory
  local install_dir
  install_dir="$(find_install_dir)"
  local symlink_path="$install_dir/git-wtr"

  log_info "Installation directory: $install_dir"

  # Check if already installed
  if [ -L "$symlink_path" ]; then
    local existing_target
    existing_target="$(readlink "$symlink_path" 2>/dev/null || true)"
    if [ "$existing_target" = "$GIT_WTR_PATH" ]; then
      log_success "git-wtr is already installed at $symlink_path"
      verify_installation
      exit 0
    else
      log_warn "Existing symlink found pointing to: $existing_target"
      log_info "Replacing with new installation..."
      if needs_sudo "$install_dir"; then
        sudo rm -f "$symlink_path"
      else
        rm -f "$symlink_path"
      fi
    fi
  elif [ -e "$symlink_path" ]; then
    log_error "A file already exists at $symlink_path (not a symlink)"
    log_error "Please remove it manually and re-run this script."
    exit 1
  fi

  # Create directory if needed
  if [ ! -d "$install_dir" ]; then
    log_info "Creating directory: $install_dir"
    mkdir -p "$install_dir"
  fi

  # Create symlink
  if needs_sudo "$install_dir"; then
    log_info "Creating symlink (requires sudo)..."
    sudo ln -s "$GIT_WTR_PATH" "$symlink_path"
  else
    log_info "Creating symlink..."
    ln -s "$GIT_WTR_PATH" "$symlink_path"
  fi

  log_success "Symlink created: $symlink_path -> $GIT_WTR_PATH"
  echo

  # Check if install_dir is in PATH
  if ! in_path "$install_dir"; then
    log_warn "$install_dir is not in your PATH"
    echo
    echo "Add this to your shell configuration file (~/.zshrc or ~/.bashrc):"
    echo
    echo "  export PATH=\"$install_dir:\$PATH\""
    echo
    echo "Then restart your terminal or run: source ~/.zshrc"
    echo
  fi

  verify_installation
}

verify_installation() {
  echo
  log_info "Verifying installation..."

  # Try to find git-wtr in PATH
  if command -v git-wtr >/dev/null 2>&1; then
    log_success "git-wtr found in PATH: $(command -v git-wtr)"
  else
    log_warn "git-wtr not found in PATH (restart your terminal or update PATH)"
  fi

  # Try running git wtr
  if git wtr version >/dev/null 2>&1; then
    local version
    version="$(git wtr version 2>/dev/null)"
    log_success "Installation verified: $version"
    echo
    echo "You can now use git wtr commands:"
    echo "  git wtr new <branch>      # Create a new worktree"
    echo "  git wtr list              # List all worktrees"
    echo "  git wtr help              # Show all commands"
  else
    log_warn "git wtr command not working yet"
    echo
    echo "If you added the PATH export above, restart your terminal and try:"
    echo "  git wtr version"
  fi
}

main "$@"
