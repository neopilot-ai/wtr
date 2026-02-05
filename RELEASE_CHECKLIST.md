# wtr v2.1.0 Release Checklist

Use this checklist to publish the v2.1.0 release to GitHub and other channels.

---

## Pre-Release Verification ✅

- [x] Version bumped to 2.1.0 in `bin/wtr`
- [x] VERSION file created with "2.1.0"
- [x] CHANGELOG.md created with complete change log
- [x] RELEASE_NOTES.md created with detailed notes
- [x] RELEASE_v2.1.0_SUMMARY.md created
- [x] All 23 adapters standardized and tested
- [x] Documentation (8 files, 7,000+ lines) complete
- [x] Examples (5 workflows, 2,900+ lines) complete
- [x] Security fixes verified (5 vulnerabilities)
- [x] Backward compatibility confirmed

---

## GitHub Release Steps

### Step 1: Verify Local Changes

```bash
cd /workspaces/wtr

# Check version
grep "WTR_VERSION" bin/wtr
# Should output: WTR_VERSION="2.1.0"

# Verify release files
ls -lh VERSION CHANGELOG.md RELEASE_NOTES.md

# Verify no uncommitted changes
git status
```

### Step 2: Create Git Tag

```bash
# Create annotated tag
git tag -a v2.1.0 -m "Release version 2.1.0

Summary: Standardized adapter system, comprehensive documentation, 
production-ready examples, and security hardening.

Key improvements:
- 23/23 adapters standardized
- 7,000+ lines of documentation
- 5 production-ready examples
- 5 security vulnerabilities fixed
- 30+ new utility functions

See RELEASE_NOTES.md for complete details."

# Verify tag
git tag -l v2.1.0 -n5
```

### Step 3: Push Tag to GitHub

```bash
# Push single tag
git push origin v2.1.0

# Or push all tags
git push origin --tags

# (Or push changes and tags in one command)
git push origin main --tags
```

### Step 4: Create GitHub Release

Via GitHub UI at https://github.com/neopilot-ai/wtr/releases/new

1. **Choose tag:** Select `v2.1.0`
2. **Release title:** `Release v2.1.0 - Adapter Standardization & Documentation`
3. **Release notes:** Copy content from [RELEASE_NOTES.md](RELEASE_NOTES.md)
4. **Mark as latest:** ✅ Check "Set as the latest release"
5. **Pre-release:** ❌ Uncheck unless providing beta
6. **Publish release:** Click "Publish release"

### Alternative: Command-Line Release

Using `gh` CLI:

```bash
gh release create v2.1.0 \
  --title "Release v2.1.0 - Adapter Standardization & Documentation" \
  --notes-file RELEASE_NOTES.md
```

---

## Post-Release Notifications

### Step 1: Update Main README

Optionally update the top section of [README.md](README.md) to reference v2.1.0:

```markdown
## Latest Release

**v2.1.0** - February 5, 2025

✨ [Complete feature list](RELEASE_NOTES.md) | 📖 [Migration guide](CHANGELOG.md#migration-guide-20x--210)
```

### Step 2: Announce on Channels

Choose where to announce (optional):

- **GitHub Discussions:** https://github.com/neopilot-ai/wtr/discussions
  - Create "Announcements" post with link to release
  - Title: "🎉 wtr v2.1.0 Released - Standardized Adapters & Comprehensive Documentation"
  
- **Reddit/Twitter/etc:** (if relevant to your audience)
  - Highlight: "23 adapters standardized, 7000+ new docs, production examples"
  - Link: https://github.com/neopilot-ai/wtr/releases/tag/v2.1.0

- **Email list:** (if you have one)
  - Template in [RELEASE_v2.1.0_SUMMARY.md](RELEASE_v2.1.0_SUMMARY.md)

### Step 3: Update Documentation Pointers

If you maintain external docs/websites:

- Point to new [docs/](docs/) directory
- Link users to [ADAPTERS-improved.md](docs/ADAPTERS-improved.md)
- Share examples from [examples/](examples/)

---

## Release Artifacts Summary

### Key Files

| File | Purpose | Lines |
|------|---------|-------|
| `VERSION` | Version reference | 1 |
| `bin/wtr` | Main executable (v2.1.0) | Updated |
| `CHANGELOG.md` | Complete version history | 520 |
| `RELEASE_NOTES.md` | Public release notes | 380 |
| `RELEASE_v2.1.0_SUMMARY.md` | Internal summary | 450 |
| `adapters/lib.sh` | Utility library | 350+ |

### Documentation Added

```
docs/
├── INDEX.md (navigation)
├── ADAPTERS-improved.md (2,000+ lines)
├── quick-reference.md (command reference)
├── faq.md (common questions)
├── errors.md (error codes)
├── setup.md (installation)
├── basic-workflow.md (getting started)
└── INTEGRATION_GUIDE.md (500+ lines)
```

### Examples Added

```
examples/
├── parallel_development.sh
├── run_services.sh
├── monorepo_workflow.sh
├── ci_integration.sh
├── team_collaboration.sh
├── .wtrconfig.example
└── hooks/
    ├── post-create.sh
    ├── pre-create.sh
    └── post-remove.sh
```

### Enhancements

- All 23 adapters (14 editors + 9 AI tools) standardized
- Security hardening (5 vulnerabilities fixed)
- Test coverage enhanced (+200 lines)

---

## Verification Commands

After release is live:

```bash
# Verify tag exists
git tag -l | grep v2.1.0

# Verify release is on GitHub
gh release list --limit 1

# Verify version matches
wtr --version
# Should show: wtr version 2.1.0

# Verify key files are accessible
curl -s https://raw.githubusercontent.com/neopilot-ai/wtr/v2.1.0/VERSION
# Should show: 2.1.0
```

---

## Rollback (If Needed)

If you need to unpublish:

```bash
# Delete local tag
git tag -d v2.1.0

# Delete remote tag
git push origin :refs/tags/v2.1.0

# Delete GitHub release
# (Done via Github UI → Releases → Delete)
```

---

## Next Release Cycle (v2.2.0)

### Planned Features

1. **Adapter Registry**
   - Centralized adapter discovery
   - Community adapter submission

2. **Performance Metrics**
   - Runtime statistics
   - Performance profiling

3. **Enhanced Telemetry**
   - Usage statistics (opt-in)
   - Error reporting

4. **Additional Integration**
   - More IDE adapters
   - CI/CD platform adapters

5. **Local LLM Support**
   - Ollama integration
   - llama.cpp support

---

## Release Notes Archive

For future releases, use as template:

1. Update `VERSION` file
2. Update version in `bin/wtr`
3. Update `CHANGELOG.md` with new section
4. Create/update `RELEASE_NOTES.md`
5. Create summary document
6. Tag and push to GitHub
7. Create GitHub release
8. Announce via channels

---

## Questions?

- 🐛 Finding issues? [Report on GitHub](https://github.com/neopilot-ai/wtr/issues)
- 💬 Have suggestions? [Discuss on GitHub](https://github.com/neopilot-ai/wtr/discussions)
- 📖 Need help? [Read the docs](docs/)

---

**Release Status:** ✅ READY FOR PUBLICATION

All files created and verified. Ready to be published to GitHub.
