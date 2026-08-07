# Release Documentation

This directory contains release-related documentation for the `wtr` project.

## 📋 Release Process

- [**Release Checklist**](RELEASE_CHECKLIST.md) - Pre-release verification steps
- [**Release Notes Template**](RELEASE_NOTES.md) - Template for writing release notes

## 📝 Release History

- [**v2.1.0 Summary**](RELEASE_v2.1.0_SUMMARY.md) - Detailed summary of the v2.1.0 release

## 🔖 Versioning

This project follows [Semantic Versioning](https://semver.org/).

- **Major** (`x.0.0`): Breaking changes
- **Minor** (`x.y.0`): New features, backward compatible
- **Patch** (`x.y.z`): Bug fixes, backward compatible

Current version: `2.1.0` (see [VERSION](../VERSION) at repository root)

## 🚀 Release Workflow

1. Update [CHANGELOG.md](../CHANGELOG.md) with release notes
2. Update [VERSION](../VERSION) file
3. Run through [Release Checklist](RELEASE_CHECKLIST.md)
4. Create Git tag: `git tag v{x.y.z}`
5. Push tag: `git push origin v{x.y.z}`
6. GitHub Actions will build and publish
7. Update [Release Notes](RELEASE_NOTES.md) with final details

## 🔗 Related

- [Main CHANGELOG](../CHANGELOG.md)
- [Contributing Guide](../CONTRIBUTING.md)
- [GitHub Releases](https://github.com/neopilot-ai/wtr/releases)