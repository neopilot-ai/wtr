# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2025-02-05

### 🎉 Major Improvements

This release includes substantial enhancements across security, documentation, examples, and the adapter system.

### Added

#### Core System
- **Adapter Library System** (`adapters/lib.sh`) - 350+ lines of standardized utilities
  - Standardized logging functions (debug, info, warn, error)
  - Command discovery and validation utilities
  - Path validation and resolution
  - Configuration management
  - Safe execution helpers (`adapter_exec`, `adapter_exec_bg`)
  - Environment variable management and API key validation
  - Network connectivity checks
  - Comprehensive diagnostic utilities
  - 30+ utility functions for consistent adapter behavior

#### Documentation
- **Comprehensive ADAPTERS-improved.md** (2,000+ lines)
  - Complete adapter inventory with capabilities
  - Quick start guide for users
  - Advanced usage patterns (remote development, terminal editors, AI analysis)
  - Implementation guide with code templates
  - lib.sh function reference
  - Best practices for users and developers
  - Detailed troubleshooting with debug mode
  - Migration guide from legacy adapters
  - Adapter quality checklist

- **Quick Reference Guide** (`docs/quick-reference.md`)
  - Common commands and flags
  - Configuration options
  - Troubleshooting tips
  - Keyboard shortcuts

- **FAQ Documentation** (`docs/faq.md`)
  - Common questions and answers
  - Best practices
  - Performance optimization
  - Team workflows

- **Error Handling Guide** (`docs/errors.md`)
  - Error codes and meanings
  - Recovery procedures
  - Debugging strategies

- **Setup Guide** (`docs/setup.md`)
  - Installation instructions
  - Configuration options
  - Shell integration setup
  - Post-installation verification

- **Basic Workflow Guide** (`docs/basic-workflow.md`)
  - Getting started tutorial
  - Daily workflow examples
  - Common patterns
  - Tips and tricks

- **Integration Guide** (`docs/INTEGRATION_GUIDE.md`) (500+ lines)
  - Tool integration patterns
  - MCP server integration
  - CI/CD integration
  - IDE integration
  - Custom hooks
  - Adapter development guide

- **Documentation Index** (`docs/INDEX.md`)
  - Navigation guide for all documentation
  - Quick links to all guides

#### Examples
- **5 Workflow Examples**
  - Parallel Development Example (`examples/parallel_development.sh`)
  - Running Services Example (`examples/run_services.sh`)
  - Monorepo Workflow Example (`examples/monorepo_workflow.sh`)
  - CI Integration Example (`examples/ci_integration.sh`)
  - Team Collaboration Example (`examples/team_collaboration.sh`)

- **Configuration Examples**
  - `.wtrconfig.example` - Complete configuration template
  - `examples/README.md` (443 lines) - Comprehensive guide to examples

- **Hook Examples**
  - `post-create.sh` - Post-creation setup examples
  - `pre-create.sh` - Pre-creation validation examples
  - `post-remove.sh` - Cleanup examples

#### Adapters - All 23 Enhanced

**Editor Adapters (14 total) - Fully Standardized:**
- `cursor.sh` - Cursor IDE integration (✅ Enhanced)
- `vscode.sh` - VS Code integration (✅ Rewritten with lib.sh)
- `vscode_remote.sh` - VS Code Remote (✅ Remote/container/WSL support)
- `zed.sh` - Zed editor integration (✅ Enhanced)
- `sublime.sh` - Sublime Text integration (✅ Enhanced)
- `vim.sh` - Vim editor integration (✅ Enhanced)
- `nvim.sh` - Neovim integration (✅ Enhanced)
- `emacs.sh` - Emacs integration (✅ Enhanced)
- `idea.sh` - IntelliJ IDEA integration (✅ Enhanced)
- `webstorm.sh` - WebStorm integration (✅ Enhanced)
- `pycharm.sh` - PyCharm integration (✅ Enhanced)
- `atom.sh` - Atom editor support (✅ Maintained)
- `nano.sh` - Nano editor integration (✅ Enhanced)
- `antigravity.sh` - Antigravity cloud editor (✅ Enhanced)

**AI Tool Adapters (9 total) - Fully Standardized:**
- `claude.sh` - Claude AI integration (✅ Comprehensive rewrite)
- `gemini.sh` - Google Gemini integration (✅ API implementation)
- `copilot.sh` - GitHub Copilot integration (✅ Enhanced)
- `continue.sh` - Continue.dev extension (✅ Enhanced with setup guide)
- `aider.sh` - Aider pair programming (✅ Enhanced)
- `opencode.sh` - OpenCode interpreter (✅ Enhanced)
- `cursor.sh` - Cursor AI features (✅ Enhanced)
- `codex.sh` - OpenAI Codex integration (✅ Deprecated info added)
- `antigravity.sh` - Antigravity AI (✅ API implementation)

**Adapter Features:**
- All adapters source standardized `lib.sh` library
- Standardized command interface: `open|start`, `check|status`, `version`, `help`
- Automatic tool detection with helpful error messages
- Installation hints for missing tools
- Debug mode support (`WTR_ADAPTER_DEBUG=1`)
- API key configuration with multiple config file locations
- Network connectivity checks for API-based adapters
- Comprehensive logging and diagnostics

#### Security
- **Shell Script Security Audit** with fixes:
  - Eliminated eval-based command injection vulnerabilities in `lib/core.sh`
  - Fixed dangerous variable expansion in `lib/config.sh`
  - Added input validation in `lib/copy.sh`
  - Implemented comprehensive error handling
  - Created `IMPROVEMENTS.md` documenting all security fixes

- **MCP Server Hardening**:
  - Parameter validators for all API endpoints
  - Timeout protection (30-second maximum execution time)
  - Comprehensive audit logging for all operations
  - Environment variable validation
  - Rate limiting indicators
  - 5 security documentation files
  - Test suite for adapter contract validation

### Changed

#### Documentation Improvements
- Reorganized documentation structure for better navigation
- Added comprehensive cross-references between guides
- Improved code examples and use cases
- Enhanced troubleshooting sections with debug guidance

#### Adapter System
- All adapters follow standardized pattern using `lib.sh`
- Consistent error handling across all tools
- Unified logging and debug output
- Standardized configuration management
- Terminal and GUI adapters handle execution context properly

#### Error Handling
- Improved error messages with actionable guidance
- Added installation instructions to adapter errors
- Better error codes and exit statuses
- Comprehensive error documentation

### Fixed

- Fixed inconsistent adapter implementations
- Fixed missing error handling in editor adapters
- Fixed undefined behavior for missing tools
- Fixed incomplete configuration management
- Fixed documentation gaps in adapter system
- Fixed security vulnerabilities in shell scripts
- Fixed MCP server validation issues

### Deprecated

- OpenAI Codex adapter now properly indicates deprecation (recommends GPT-4)
- Basic legacy adapter patterns (use lib.sh instead)

### Security

- Eliminated all eval-based command execution vulnerabilities
- Added proper input validation across all shell scripts
- Implemented environment variable validation
- Added API key validation and secure handling
- Added timeout protection for long-running operations
- Comprehensive audit logging for security operations

### Documentation

Over **7,000 lines** of new documentation added:
- 6 comprehensive guides (setup, workflow, FAQ, errors, integration, reference)
- 1 documentation index
- 1 adapter system guide (2,000+ lines)
- Complete API documentation for 23 adapters
- Implementation patterns and templates
- Troubleshooting guides
- Best practices documentation

### Examples

Over **2,900 lines** of practical examples:
- 5 workflow scripts demonstrating common patterns
- Sample configuration files
- Hook examples for common scenarios
- Complete build/run examples
- Team collaboration patterns

### Performance

- No breaking changes
- All improvements are backward compatible
- Enhanced error detection improves overall reliability

## [2.0.0] - 2024-XX-XX

### Added

- Initial release with core worktree management
- Editor adapter system
- AI tool integration
- Configuration management
- Hook system
- Documentation

### Features

- Create and manage multiple Git worktrees
- Automatic branch creation
- File copying from main repo
- Hook execution
- Various editor integrations
- Basic AI tool support

---

## Version Numbering

This project follows [Semantic Versioning](https://semver.org/):

- **MAJOR** version (X.0.0): Breaking changes or major feature additions
- **MINOR** version (0.X.0): Backward-compatible feature additions
- **PATCH** version (0.0.X): Backward-compatible bug fixes

Visit [releases](https://github.com/neopilot-ai/wtr/releases) for detailed release notes.

---

## Migration Guides

### Updating from 2.0.x to 2.1.0

**All changes are backward compatible.** No action required, but you may want to:

1. Review new documentation in `/docs`
2. Explore new examples in `/examples`
3. Check adapter improvements for your favorite tools
4. Enable debug mode if you encounter issues: `export WTR_ADAPTER_DEBUG=1`

**For Adapter Developers:**

If you've created custom adapters, consider updating them to use the new `lib.sh` utilities:

```bash
# Add at top of your adapter script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ADAPTERS_DIR="$(dirname "$SCRIPT_DIR")"
[ -f "$ADAPTERS_DIR/lib.sh" ] && source "$ADAPTERS_DIR/lib.sh"

# Replace manual checks with lib.sh utilities
adapter_validate_path "$target"      # Instead of manual validation
adapter_check_command "tool"         # Instead of command -v
adapter_log_info "message"           # Instead of echo
```

See `/docs/ADAPTERS-improved.md` for complete migration guide.

---

## Acknowledgments

This release incorporates extensive improvements to:
- Security hardening
- Documentation coverage
- Adapter system standardization
- Example workflows
- Error handling and diagnostics

Thanks to all contributors and users who helped shape wtr into a robust tool for parallel development.
