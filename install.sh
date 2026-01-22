#!/usr/bin/env bash
# install.sh - installation wtr script
# Detects platform, installs files, and sets up shell integration.

set -e

# Colors for output
BOLD="\033[1m"
RESET="\033[0m"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"

log_info() { echo -e "${BLUE}[info]${RESET} $*"; }
log_success() { echo -e "${GREEN}[ok]${RESET} $*"; }
log_error() { echo -e "${RED}[error]${RESET} $*" >&2; }
log_warn() { echo -e "${YELLOW}[warn]${RESET} $*" >&2; }
log_step() { echo -e "${CYAN}==>${RESET} ${BOLD}$*${RESET}"; }

# Default values
WTR_REPO_DIR=$(cd "$(dirname "$0")" && pwd)
INSTALL_DIR="${WTR_INSTALL_DIR:-$HOME/.wtr}"
BIN_DIR="${WTR_BIN_DIR:-$HOME/.local/bin}"

# 1. Platform Detection
detect_os() {
  local os_name
  os_name="$(uname -s)"
  case "$os_name" in
    Darwin*)  echo "macos" ;;
    Linux*)   echo "linux" ;;
    *)        echo "unknown" ;;
  esac
}

detect_shell() {
  local shell_path="${SHELL:-}"
  if [ -n "$shell_path" ]; then
    echo "${shell_path##*/}"
  else
    # Fallback to checking active process if SHELL is not set
    if [ -n "$ZSH_VERSION" ]; then echo "zsh";
    elif [ -n "$BASH_VERSION" ]; then echo "bash";
    elif [ -n "$FISH_VERSION" ]; then echo "fish";
    else echo "bash"; fi
  fi
}

OS=$(detect_os)
SHELL_TYPE=$(detect_shell)

log_step "Detecting platform..."
log_info "OS: $OS"
log_info "Shell: $SHELL_TYPE"


# Handle arguments
if [ "$1" == "--uninstall" ]; then
  log_step "Uninstalling wtr..."
  rm -rf "$INSTALL_DIR"
  rm -f "$BIN_DIR/wtr"
  rm -f "$BIN_DIR/git-wtr"
  log_success "Uninstalled successfully."
  log_info "Please manually remove the wtr configuration block from your shell config file." 
  exit 0
fi

if [ "$1" == "--upgrade" ]; then
  log_info "Upgrading wtr..."
  # Just continue, as the script overwrites by default
fi

# 2. Dependency Checks
log_step "Checking dependencies..."
if ! command -v git >/dev/null 2>&1; then
  log_error "Git is required but not found. Please install Git and try again."
  exit 1
fi

if [ -n "$BASH_VERSION" ] && [ "${BASH_VERSINFO[0]:-0}" -lt 4 ]; then
  log_warn "wtr recommends Bash 4.0+. Some features might be limited in older versions."
fi

# 3. Installation Path Setup
log_step "Setting up installation directory..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"

log_info "Installing to: $INSTALL_DIR"
log_info "Binaries to: $BIN_DIR"

# 4. Copy Files
log_step "Copying files..."
for dir in bin lib adapters completions; do
  if [ -d "$WTR_REPO_DIR/$dir" ]; then
    log_info "Copying $dir/..."
    cp -R "$WTR_REPO_DIR/$dir" "$INSTALL_DIR/"
  fi
done

# Ensure binaries are executable
chmod +x "$INSTALL_DIR/bin/wtr"
chmod +x "$INSTALL_DIR/bin/git-wtr"

# 5. Symlink Binaries
log_step "Creating symlinks..."
ln -sf "$INSTALL_DIR/bin/wtr" "$BIN_DIR/wtr"
ln -sf "$INSTALL_DIR/bin/git-wtr" "$BIN_DIR/git-wtr"

# 6. Shell Integration
log_step "Configuring shell integration..."

setup_shell_config() {
  local config_file="$1"
  local content="$2"
  local marker="# wtr Config"

  if [ -f "$config_file" ]; then
    if grep -q "$marker" "$config_file"; then
      log_info "wtr config already exists in $config_file"
    else
      log_info "Adding wtr config to $config_file"
      echo -e "\n$marker\n$content" >> "$config_file"
    fi
  else
    log_info "Creating $config_file and adding wtr config"
    echo -e "$marker\n$content" > "$config_file"
  fi
}

# PATH configuration
PATH_CONFIG="export PATH=\"\$PATH:$BIN_DIR\""

case "$SHELL_TYPE" in
  bash)
    SHELL_RC="$HOME/.bashrc"
    [ "$OS" = "macos" ] && SHELL_RC="$HOME/.bash_profile"
    
    COMPLETION_CONFIG="if [ -f \"$INSTALL_DIR/completions/wtr.bash\" ]; then
  source \"$INSTALL_DIR/completions/wtr.bash\"
fi"
    setup_shell_config "$SHELL_RC" "$PATH_CONFIG\n$COMPLETION_CONFIG"
    ;;
  zsh)
    SHELL_RC="$HOME/.zshrc"
    COMPLETION_CONFIG="if [ -f \"$INSTALL_DIR/completions/wtr.zsh\" ]; then
  source \"$INSTALL_DIR/completions/wtr.zsh\"
fi"
    setup_shell_config "$SHELL_RC" "$PATH_CONFIG\n$COMPLETION_CONFIG"
    ;;
  fish)
    FISH_CONFIG_DIR="$HOME/.config/fish/conf.d"
    mkdir -p "$FISH_CONFIG_DIR"
    echo "set -gx PATH \$PATH $BIN_DIR" > "$FISH_CONFIG_DIR/wtr.fish"
    if [ -f "$INSTALL_DIR/completions/wtr.fish" ]; then
      cp "$INSTALL_DIR/completions/wtr.fish" "$HOME/.config/fish/completions/wtr.fish"
    fi
    log_info "Created fish configuration in $FISH_CONFIG_DIR/wtr.fish"
    ;;
  *)
    log_warn "Unsupported shell '$SHELL_TYPE'. Please manually add $BIN_DIR to your PATH."
    ;;
esac

log_success "wtr installed successfully!"
echo ""
echo "To start using it, restart your shell or run:"
if [ "$SHELL_TYPE" = "fish" ]; then
  echo "  source ~/.config/fish/config.fish"
else
  echo "  source $SHELL_RC"
fi
echo ""
echo "Try it out with: git wtr --version"
