# Security Policy

## Supported Versions

We release patches for security vulnerabilities. The following versions are currently supported with security updates:

| Version | Supported          |
| ------- | ------------------ |
| 2.x     | ✅                 |
| < 2.0   | ❌                 |

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via email to: **security@neopilot.ai**

You should receive a response within 48 hours. If for some reason you do not, please follow up via email to ensure we received your original message.

Please include the following information:
- Type of issue (e.g., buffer overflow, SQL injection, cross-site scripting, etc.)
- Full paths of source file(s) related to the vulnerability
- The location of the affected source code (tag/branch/commit or direct URL)
- Any special configuration required to reproduce the issue
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit it

## Disclosure Policy

- We will acknowledge receipt of your vulnerability report within 48 hours.
- We will provide a preliminary assessment within 5 business days.
- We will keep you informed of the progress towards a fix.
- We will coordinate with you on a disclosure timeline.
- We will credit you in the release notes (unless you prefer to remain anonymous).

## Security Best Practices for Users

- Always keep `wtr` updated to the latest version
- Use `git wtr doctor` to verify your setup
- Be cautious when using `--force` flags
- Review hook scripts before enabling them
- Use `gh auth login` with minimal required scopes

## Scope

This security policy applies to the `wtr` CLI tool and its associated adapters. It does not cover:
- Third-party tools integrated via adapters (e.g., VS Code, Cursor, Claude, etc.)
- Git itself or GitHub
- Your shell environment or system configuration