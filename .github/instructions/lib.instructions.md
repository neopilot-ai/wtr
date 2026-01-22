# Library Modification Guidelines

- **Statelessness**: Library functions should ideally be stateless or rely on well-defined globals from `lib/config.sh` or `bin/wtr`.
- **Naming**: Prefix internal functions with `_` if they shouldn't be called directly by command handlers.
- **Portability**: Stick to `[ ]` for tests and standard `sed`/`awk`/`grep` flags.
- **Error Handling**: Functions should return non-zero on failure and use `log_error` for details.
- **Modularity**:
  - `lib/core.sh`: Git-specific operations.
  - `lib/config.sh`: Config parsing and persistence.
  - `lib/ui.sh`: All user interactions (logs, prompts).
  - `lib/platform.sh`: OS detection and compatibility layers.
