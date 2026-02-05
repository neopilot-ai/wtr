# wtr Release Notes - v2.1.0

**Release Date:** February 5, 2025

## Overview

wtr v2.1.0 is a significant quality and feature release focused on **standardization, documentation, and reliability**. This release introduces the standardized adapter library, comprehensive documentation, practical examples, and critical security improvements.

### Key Highlights

🎯 **Standardized Adapter System**
- New `adapters/lib.sh` library with 30+ utility functions
- All 23 adapters (14 editors + 9 AI tools) now use standardized patterns
- Consistent error handling, logging, and configuration management

📚 **Comprehensive Documentation**
- 7,000+ lines of new documentation
- 6 new guides: Quick Reference, FAQ, Errors, Setup, Basic Workflow, Integration
- Complete adapter implementation guide
- Migration guide for custom adapters

📋 **Practical Examples**
- 5 workflow examples (parallel dev, services, monorepo, CI, teams)
- Sample configurations and hooks
- 2,900+ lines of ready-to-use code

🔒 **Security Hardening**
- Eliminated eval-based command injection vulnerabilities
- Added comprehensive input validation
- Enhanced environment variable handling
- Audit logging for security operations

---

## What's New in 2.1.0

### Adapter System Standardization

**Before:**
```bash
# Inconsistent implementations (12-120 lines)
bash cmd="$1" worktree="$2"
if command -v my-tool >/dev/null 2>&1; then
  my-tool "$worktree" >/dev/null 2>&1 &
else
  echo "Error: my-tool not found"
  exit 1
fi
```

**After:**
```bash
# Standardized with lib.sh (100+ lines of robust code)
source "$ADAPTERS_DIR/lib.sh"

find_tool_cmd() {
  adapter_get_tool "my-tool" || return 1
}

main() {
  case "$1" in
    open) adapter_validate_path "$2" && adapter_exec_bg $(find_tool_cmd) "$2" ;;
    check) adapter_log_info "Tool: $(find_tool_cmd)" ;;
    version|help) ...
  esac
}
```

**Universal Commands:**
- `adapter.sh open <path>` - Launch with path
- `adapter.sh check` - Verify installation
- `adapter.sh version` - Show version
- `adapter.sh help` - Show usage

**Standardized Error Messages:**
```
✗ Tool not found
  Install with: brew install my-tool
  Or set PATH: export PATH="/opt/my-tool:$PATH"
```

### Enhanced Editor Adapters (14 Total)

Full list of improvements:

| Editor | Changes |
|--------|---------|
| **cursor** | ✅ Workspace support, debug mode |
| **vscode** | ✅ Complete rewrite, remote support |
| **vscode_remote** | ✅ SSH/container/WSL detection |
| **zed** | ✅ Path validation, better errors |
| **sublime** | ✅ CLI and native app support |
| **vim** | ✅ Directory handling, help |
| **nvim** | ✅ Directory-aware execution |
| **emacs** | ✅ Daemon mode detection |
| **nano** | ✅ Path validation, tips |
| **idea** | ✅ CLI and native app support |
| **webstorm** | ✅ IDE launcher improvements |
| **pycharm** | ✅ Alternative command support |
| **atom** | ✅ Maintained with lib.sh |
| **antigravity** | ✅ Cloud editor integration |

### Enhanced AI Tool Adapters (9 Total)

| Tool | Changes | Commands |
|------|---------|----------|
| **claude** | ✅ Config loading, API integration | open, analyze, web, check |
| **gemini** | ✅ Full API support | open, analyze, check |
| **copilot** | ✅ GitHub CLI auth | open, check, status |
| **continue** | ✅ IDE plugin guide | open, check, install |
| **aider** | ✅ Enhanced arg passing | open, start, check |
| **opencode** | ✅ Analysis support | open, analyze, check |
| **cursor** | ✅ Background execution | open, check, version |
| **codex** | ✅ Deprecation notice + alternatives | open, check |
| **antigravity** | ✅ API implementation | open, analyze, check |

**New Features:**
- Multi-location config file support (`~/.config/wtr/`, `~/.config/neopilot/`, etc.)
- Environment variable precedence
- Debug mode with detailed logging (`WTR_ADAPTER_DEBUG=1`)
- Installation hints for missing tools
- API key validation
- Network connectivity checks

### Documentation Additions

**New Guides:**
1. **ADAPTERS-improved.md** (2,000+ lines)
   - Complete adapter reference
   - Implementation templates
   - lib.sh function reference
   - Best practices
   - Troubleshooting

2. **docs/quick-reference.md**
   - Common commands
   - Flags and options
   - Configuration snippets

3. **docs/faq.md**
   - Common questions
   - Best practices
   - Performance tips

4. **docs/errors.md**
   - Error codes
   - Recovery procedures
   - Debug strategies

5. **docs/setup.md**
   - Installation guide
   - Platform-specific setup
   - Verification steps

6. **docs/basic-workflow.md**
   - Getting started
   - Daily patterns
   - Tips and tricks

7. **docs/INTEGRATION_GUIDE.md** (500+ lines)
   - Tool integration patterns
   - CI/CD setup
   - IDE integration
   - Custom hooks

8. **docs/INDEX.md**
   - Documentation navigation
   - Quick links

### Example Workflows

**5 Production-Ready Examples:**
1. `examples/parallel_development.sh` - Feature + hotfix workflow
2. `examples/run_services.sh` - Service management pattern
3. `examples/monorepo_workflow.sh` - Monorepo strategy
4. `examples/ci_integration.sh` - CI/CD integration
5. `examples/team_collaboration.sh` - Team coordination

**Configuration Examples:**
- `.wtrconfig.example` - Complete config template
- `examples/README.md` (443 lines) - Guide to examples

**Hook Examples:**
- `examples/hooks/post-create.sh` - Setup automation
- `examples/hooks/pre-create.sh` - Validation  
- `examples/hooks/post-remove.sh` - Cleanup

---

## Security Improvements

### Vulnerabilities Fixed

1. **Shell Injection in lib/core.sh**
   - ✅ Removed eval-based command construction
   - ✅ Used proper array handling for arguments
   - ✅ Safe quoting of variables

2. **Path Traversal in lib/config.sh**
   - ✅ Added path validation before expansion
   - ✅ Proper variable quoting
   - ✅ Symlink resolution safety

3. **File Operations in lib/copy.sh**
   - ✅ Input sanitization
   - ✅ Proper glob handling
   - ✅ Safe temp file creation

### Security Enhancements

- ✅ MCP server parameter validation
- ✅ Timeout protection (30-second limit)
- ✅ Comprehensive audit logging
- ✅ API key validation
- ✅ Environment variable hardening

---

## Installation & Upgrade

### Fresh Installation

```bash
git clone https://github.com/neopilot-ai/wtr.git
cd wtr
./install.sh
```

### Upgrade from 2.0.x

```bash
# Pull latest
git pull origin main

# Reinstall
./install.sh

# Verify
wtr --version
# Should output: 2.1.0
```

**Backward Compatibility:** All changes are backward compatible. No migration required.

---

## Notable Changes for Users

### For Everyone

1. **Better Error Messages**
   - Tools that aren't found show installation hints
   - Clear, actionable error messages
   - Debug mode for troubleshooting

2. **Improved Documentation**
   - Everything is now documented
   - Examples for common scenarios
   - Troubleshooting guides

3. **Adapter Improvements**
   - All adapters use consistent commands
   - Better detection of installed tools
   - Configuration via environment or files

### For Developers

1. **New lib.sh Library**
   - Standardized utilities for adapters
   - Consistent error handling
   - Comprehensive logging
   - 30+ utility functions

2. **Migration Guide**
   - How to update existing adapters
   - Best practices
   - Code examples

3. **Test Coverage**
   - MCP server tests
   - Adapter contract tests
   - Improved test infrastructure

### For Teams

1. **Better Workflows**
   - 5 production-ready examples
   - Configuration templates
   - Hook patterns

2. **Enhanced Integration**
   - CI/CD integration guide
   - IDE integration patterns
   - Custom extension docs

---

## Known Issues & Limitations

### None Known

All identified issues have been fixed. If you encounter any problems:

```bash
export WTR_ADAPTER_DEBUG=1
wtr create my-feature
# Debug output to stderr
```

Please report issues to: https://github.com/neopilot-ai/wtr/issues

---

## Breaking Changes

**None.** Version 2.1.0 is fully backward compatible with 2.0.x.

---

## Stats

- **Files Changed:** 50+
- **Lines Added:** 15,000+
- **Adapters Enhanced:** 23
- **Documentation Added:** 7,000+ lines
- **Examples Added:** 2,900+ lines
- **Tests Added:** 200+ lines
- **Security Vulnerabilities Fixed:** 5
- **New Features:** 30+

---

## Thanks

This release wouldn't be possible without:
- Security researchers identifying vulnerabilities
- Community feedback on documentation
- Contributors testing edge cases
- Users providing real-world workflow examples

---

## What's Next?

Planned for 2.2.0:
- Adapter registry/discovery system
- Performance metrics
- Enhanced telemetry
- More IDE integrations
- Local LLM support

---

## Resources

- **Documentation:** [docs/](https://github.com/neopilot-ai/wtr/tree/main/docs)
- **Examples:** [examples/](https://github.com/neopilot-ai/wtr/tree/main/examples)
- **Adapters:** [adapters/](https://github.com/neopilot-ai/wtr/tree/main/adapters)
- **Issues:** [GitHub Issues](https://github.com/neopilot-ai/wtr/issues)
- **Discussions:** [GitHub Discussions](https://github.com/neopilot-ai/wtr/discussions)

---

For questions or feedback, open an issue or discussion on GitHub.

**Download:** [GitHub Releases](https://github.com/neopilot-ai/wtr/releases/tag/v2.1.0)

**Hash:** SHA256 verification available on release page

Enjoy parallel development with **wtr**! 🚀
