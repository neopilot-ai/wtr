# wtr Examples Directory

> Complete collection of practical examples for using wtr in different scenarios

---

## 📂 Examples Overview

This directory contains **production-ready examples** demonstrating various wtr use cases and configurations.

**Quick Start**: Browse the files below to find examples relevant to your workflow.

---

## 🚀 Quick Start Examples

### 1. **parallel_development.example.sh** - Multiple Features Simultaneously
**Use When**: Working on multiple features at the same time

```bash
# Create and manage 3 features in parallel
./examples/parallel_development.example.sh

# Features demonstrated:
# - Create auth-login feature branch
# - Create api-v2 feature branch  
# - Create ui-redesign feature branch
# - Switch between them instantly
# - Run setup independently
```

**Key Features**:
- 👥 Parallel feature management
- 🔄 Quick context switching
- 📋 Interactive feature selection
- 🎯 Per-feature setup and testing

---

### 2. **run_services.example.sh** - Service Orchestration
**Use When**: Running microservices or coordinated services

```bash
chmod +x examples/run_services.example.sh
./examples/run_services.example.sh

# Or for CI/CD:
./examples/run_services.example.sh --automated
```

**Services Demonstrated**:
- 🎯 API service (port 3000)
- 🌐 Web service (port 3001)
- ⚙️ Worker service (port 3002)
- ⏰ Scheduler service (port 9000)

**Key Features**:
- 🚀 Start all services in parallel
- 📊 Service health checks
- 🧪 Run tests per service
- 🎨 Interactive menu + automated mode
- 🧹 Graceful cleanup

---

### 3. **monorepo_workflow.example.sh** - Monorepo Project Management
**Use When**: Working with Turborepo, Nx, Lerna, etc.

```bash
./examples/monorepo_workflow.example.sh

# Supports:
# - Turborepo
# - Nx
# - Lerna
# - pnpm workspaces
```

**Key Features**:
- 🏗️ Auto-detect monorepo tool
- 📦 Package-specific workflows
- 🔗 Dependency management
- 🎯 Build and test individual packages
- 🌳 Cross-package coordination

---

### 4. **ci_integration.example.sh** - CI/CD Pipeline Integration
**Use When**: Running wtr in GitHub Actions, GitLab CI, Jenkins, etc.

```bash
./examples/ci_integration.example.sh

# Auto-detects:
# - GitHub Actions
# - GitLab CI
# - Jenkins
```

**Key Features**:
- ✅ PR validation workflows
- 🧪 Comprehensive test suites
- 📊 Test report generation
- 🧹 Automatic cleanup
- 🔄 Integration test runs

---

### 5. **team_collaboration.example.sh** - Team Workflows
**Use When**: Multiple developers using wtr together

```bash
./examples/team_collaboration.example.sh
```

**Workflow Patterns**:
- 👥 Feature development (assign to team members)
- 🔍 Code review worktrees
- 🚨 Hotfix coordination
- ⚡ Emergency bug fixes
- 💬 Team communication patterns

---

## ⚙️ Configuration Examples

### **.wtrconfig.example** - Complete Configuration Reference
**Use When**: Setting up project-level wtr configuration

```bash
# Copy example to your repo:
cp examples/.wtrconfig.example .wtrconfig

# Edit for your project:
cat .wtrconfig
```

**Sections**:
- `[defaults]` - Global defaults (editor, AI, directory)
- `[copy]` - Files to auto-copy to worktrees
- `[hooks]` - Lifecycle scripts
- `[presets]` - Named configurations
- `[ignore]` - Patterns to exclude
- `[build]` - Build automation
- `[test]` - Test automation
- `[ci]` - CI/CD configuration

**Example Presets Included**:
- `frontend` - Frontend development setup
- `backend` - Backend development setup
- `devops` - Infrastructure/DevOps setup
- `hotfix` - Emergency fix setup

---

## 🪝 Hook Examples

### **hooks/preCreate.example.sh** - Pre-Creation Validation
**Runs**: BEFORE worktree creation

```bash
# Copy to your repo:
cp examples/hooks/preCreate.example.sh .wtr/hooks/preCreate
chmod +x .wtr/hooks/preCreate
```

**Validations**:
- ✅ Git repository check
- 📊 Disk space verification
- 💾 Memory availability
- 📡 Network connectivity
- 🔬 Branch quality checks
- 📦 Dependency availability

**Use For**:
- Pre-flight checks
- Resource validation
- Branch verification

---

### **hooks/postCreate.example.sh** - Setup After Creation
**Runs**: IN the new worktree, AFTER creation

```bash
# Copy to your repo:
cp examples/hooks/postCreate.example.sh .wtr/hooks/postCreate
chmod +x .wtr/hooks/postCreate
```

**Project Type Support**:
- 🔵 Node.js / JavaScript (npm, yarn, pnpm)
- 🐍 Python (pip, venv)
- 💎 Ruby (Bundler, Rails)
- 🐹 Go (go mod)
- 🦀 Rust (Cargo)

**Setup Tasks**:
- 📦 Install dependencies
- 🔨 Build projects
- ⚙️ Configure environment
- 🗄️ Setup databases
- 🧪 Run initial tests
- 🏥 Health checks

---

### **hooks/postRemove.example.sh** - Cleanup After Removal
**Runs**: AFTER worktree removal (in main repo)

```bash
# Copy to your repo:
cp examples/hooks/postRemove.example.sh .wtr/hooks/postRemove
chmod +x .wtr/hooks/postRemove
```

**Cleanup Tasks**:
- 🗑️ Remove temporary files
- 🔧 Git maintenance (gc, prune)
- 🌳 Clean up branches
- 📤 Optional auto-push
- 📊 Generate reports
- 👥 Team notifications

---

## 📋 Complete File List

### Workflow Examples
| File | Purpose | Lines |
|------|---------|-------|
| `parallel_development.example.sh` | Multiple features in parallel | 100+ |
| `run_services.example.sh` | Microservices orchestration | 360+ |
| `monorepo_workflow.example.sh` | Monorepo management | 180+ |
| `ci_integration.example.sh` | CI/CD integration | 200+ |
| `team_collaboration.example.sh` | Team workflows | 250+ |

### Configuration Examples
| File | Purpose | Lines |
|------|---------|-------|
| `.wtrconfig.example` | Complete config reference | 250+ |
| `presets.gitconfig` | Git config presets | 50+ |

### Hook Examples
| File | Purpose | Lines |
|------|---------|-------|
| `hooks/preCreate.example.sh` | Pre-creation validation | 260+ |
| `hooks/postCreate.example.sh` | Setup after creation | 450+ |
| `hooks/postRemove.example.sh` | Cleanup after removal | 360+ |

---

## 🚀 Getting Started

### Step 1: Choose Your Use Case

Find the scenario that best matches your workflow:
- Working solo on multiple features? → `parallel_development.example.sh`
- Running microservices? → `run_services.example.sh`
- Monorepo project? → `monorepo_workflow.example.sh`
- Team collaboration? → `team_collaboration.example.sh`
- CI/CD pipeline? → `ci_integration.example.sh`

### Step 2: Copy and Customize

```bash
# Copy the example
cp examples/YOUR_EXAMPLE.sh ./my_workflow.sh

# Make executable
chmod +x ./my_workflow.sh

# Customize for your project
vim ./my_workflow.sh

# Run it!
./my_workflow.sh
```

### Step 3: Set Up Configuration

```bash
# Copy config example
cp examples/.wtrconfig.example .wtrconfig

# Customize for your project
vim .wtrconfig

# Commit to git for team
git add .wtrconfig
git commit -m "Add wtr configuration"
```

### Step 4: Setup Hooks (Optional)

```bash
# Create hooks directory
mkdir -p .wtr/hooks

# Copy hook examples
cp examples/hooks/*.example.sh .wtr/hooks/
# Remove .example.sh suffix
mv .wtr/hooks/postCreate.example.sh .wtr/hooks/postCreate
mv .wtr/hooks/preCreate.example.sh .wtr/hooks/preCreate
mv .wtr/hooks/postRemove.example.sh .wtr/hooks/postRemove

# Make executable
chmod +x .wtr/hooks/*

# Customize if needed
vim .wtr/hooks/postCreate

# Commit to git for team
git add .wtr/hooks
git commit -m "Add wtr lifecycle hooks"
```

---

## 🎯 Use Case Quick Reference

| Scenario | Example | Config | Hooks |
|----------|---------|--------|-------|
| Solo development | `parallel_development.example.sh` | `.wtrconfig.example` | `postCreate.example.sh` |
| Microservices | `run_services.example.sh` | `.wtrconfig.example` | All hooks |
| Monorepo | `monorepo_workflow.example.sh` | `.wtrconfig.example` | All hooks |
| Team project | `team_collaboration.example.sh` | `.wtrconfig.example` | All hooks |
| CI/CD pipeline | `ci_integration.example.sh` | N/A | N/A |

---

## 💡 Tips & Tricks

### Combine Examples
Mix and match examples for your specific workflow:

```bash
# Start with parallel development script
./examples/parallel_development.example.sh

# But use team collaboration patterns
./examples/team_collaboration.example.sh

# And monorepo setup if applicable
./examples/monorepo_workflow.example.sh
```

### Customize Hooks
Hooks are the most customizable part. Start with examples and adapt:

```bash
# Start with post-create example
cp examples/hooks/postCreate.example.sh .wtr/hooks/postCreate

# Edit to include your specific setup
vim .wtr/hooks/postCreate

# Comment out sections you don't need
# Keep sections relevant to your project
```

### Create Your Own Presets
Use `.wtrconfig.example` as a template:

```bash
# Copy example
cp examples/.wtrconfig.example .wtrconfig

# Add your presets
cat >> .wtrconfig <<EOF

[preset.my-workflow]
    branch = develop
    copy = .env.custom
    hook.postCreate = npm install && npm run build
EOF
```

---

## 🔗 Learn More

- **Configuration**: See `.wtrconfig.example` for all options
- **Hooks**: Check hook examples in `hooks/` directory
- **Documentation**: Read [Comprehensive Guide](../docs/INTEGRATION_GUIDE.md)
- **Quick Reference**: [Quick Reference Card](../docs/quick-reference.md)
- **FAQ**: Common questions in [FAQ](../docs/faq.md)

---

## 📊 Examples Statistics

```
Total Example Files: 9
Total Lines of Code: 2,500+
Coverage Areas: 5+
Supported Project Types: 6+ (Node, Python, Ruby, Go, Rust, etc.)
Monorepo Tools: 3 (Turborepo, Nx, Lerna)
CI/CD Platforms: 3 (GitHub Actions, GitLab CI, Jenkins)
```

---

## ✅ What You'll Learn

From these examples, you'll understand how to:

1. ✅ Create and manage multiple worktrees
2. ✅ Set up parallel development workflows
3. ✅ Orchestrate multiple services
4. ✅ Work with monorepos effectively
5. ✅ Integrate with CI/CD pipelines
6. ✅ Collaborate as a team
7. ✅ Write and customize hooks
8. ✅ Configure wtr for your project
9. ✅ Auto-setup with post-create hooks
10. ✅ Auto-cleanup with post-remove hooks

---

## 🤝 Contributing Examples

Have a great wtr example? Contribute it!

1. Create `examples/your-workflow.example.sh`
2. Add extensive comments
3. Make it production-ready
4. Document in this README
5. Submit a PR!

---

## 📝 License

All examples are provided under the same license as wtr (Apache 2.0).

---

**Last Updated**: February 2026  
**Version**: 2.0+

For more information, see: [Documentation Index](../docs/INDEX.md)
