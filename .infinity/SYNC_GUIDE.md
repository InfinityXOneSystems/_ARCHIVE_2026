# 🔄 Infinity X One Systems - Master Sync Guide

## Overview

This repository includes a **production-grade master sync system** for maintaining perfect synchronization between your remote GitHub repository and local development environment. The system provides both **manual sync scripts** and **automated live persistent sync** via GitHub Actions.

---

## 🎯 Features

### ✨ Core Capabilities
- **Bidirectional Sync**: Seamlessly sync changes in both directions (Remote ⟷ Local)
- **Live Persistent Sync**: Automated workflows ensure continuous synchronization
- **Conflict Resolution**: Intelligent handling of merge conflicts with configurable strategies
- **Cross-Platform**: Works on Windows (PowerShell), macOS, and Linux (Bash)
- **Robust Error Handling**: Production-grade error detection, logging, and recovery
- **Status Tracking**: Real-time sync status via ACTIVE_MEMORY.md
- **Automated Scheduling**: Hourly auto-sync and 15-minute bidirectional checks
- **Manual Triggers**: On-demand sync via command line or GitHub Actions

---

## 📦 Installation & Setup

### Prerequisites
- Git 2.x or higher
- PowerShell 5.1+ (Windows) or Bash 4.0+ (Unix/Linux/Mac)
- GitHub repository access (read/write permissions)

### Quick Start

1. **Clone the Repository** (if not already cloned):
   ```bash
   git clone https://github.com/Infinity-X-One-Systems/_ARCHIVE_2026.git
   cd _ARCHIVE_2026
   ```

2. **Verify Structure**:
   ```bash
   ls -la .infinity/
   ls -la scripts/
   ls -la .github/workflows/
   ```

3. **Test the Sync Scripts**:
   
   **On Windows (PowerShell)**:
   ```powershell
   .\scripts\Sync-Repository.ps1 -Mode bidirectional -DryRun
   ```
   
   **On macOS/Linux (Bash)**:
   ```bash
   ./scripts/sync-repository.sh --mode bidirectional --dry-run
   ```

---

## 🚀 Usage

### Manual Synchronization

#### Windows (PowerShell)

**Basic Sync** (Pull + Push):
```powershell
.\scripts\Sync-Repository.ps1
```

**Pull Only** (Remote → Local):
```powershell
.\scripts\Sync-Repository.ps1 -Mode pull
```

**Push Only** (Local → Remote):
```powershell
.\scripts\Sync-Repository.ps1 -Mode push
```

**Force Sync** (Override uncommitted changes warning):
```powershell
.\scripts\Sync-Repository.ps1 -Mode bidirectional -Force
```

**Dry Run** (Preview without executing):
```powershell
.\scripts\Sync-Repository.ps1 -Mode bidirectional -DryRun
```

**Sync Specific Branch**:
```powershell
.\scripts\Sync-Repository.ps1 -Mode bidirectional -Branch main
```

#### macOS/Linux (Bash)

**Basic Sync**:
```bash
./scripts/sync-repository.sh
```

**Pull Only**:
```bash
./scripts/sync-repository.sh --mode pull
```

**Push Only**:
```bash
./scripts/sync-repository.sh --mode push
```

**Force Sync**:
```bash
./scripts/sync-repository.sh --mode bidirectional --force
```

**Dry Run**:
```bash
./scripts/sync-repository.sh --mode bidirectional --dry-run
```

**Sync Specific Branch**:
```bash
./scripts/sync-repository.sh --mode bidirectional --branch main
```

---

## ⚙️ Configuration

### Sync Configuration File: `.infinity/sync-config.json`

Customize sync behavior by editing this file:

```json
{
  "sync": {
    "mode": "bidirectional",           // pull, push, or bidirectional
    "strategy": "merge",               // merge or rebase
    "conflictResolution": "remote-first", // remote-first or local-first
    "autoCommit": true,                // Auto-commit changes
    "autoPush": true,                  // Auto-push after commit
    "frequency": {
      "enabled": true,
      "schedule": "0 * * * *"          // Cron: every hour
    }
  },
  "paths": {
    "include": ["*"],
    "exclude": [
      "node_modules",
      "*.log",
      ".env"
    ]
  },
  "security": {
    "protectedBranches": ["main", "master", "develop"]
  }
}
```

### Environment Variables (Optional)

For enhanced security and customization:

```bash
# Set Git credentials (if not using SSH)
export GIT_USERNAME="your-username"
export GIT_TOKEN="ghp_xxxxxxxxxxxx"

# Custom remote name
export GIT_REMOTE="origin"

# Default branch
export GIT_DEFAULT_BRANCH="main"
```

---

## 🤖 Automated Workflows

### Auto Sync Workflow (`.github/workflows/auto-sync.yml`)

**Triggers:**
- Push to any branch
- Hourly schedule (every hour at :00)
- Manual dispatch

**Actions:**
- Fetches latest changes from remote
- Pulls changes with automatic rebase
- Commits any local changes
- Pushes to remote
- Updates ACTIVE_MEMORY.md with sync status

**Manual Trigger:**
```bash
# Via GitHub CLI
gh workflow run auto-sync.yml

# Via GitHub Web UI
Actions → Auto Sync Repository → Run workflow
```

### Bidirectional Live Sync (`.github/workflows/bidirectional-sync.yml`)

**Triggers:**
- Push to any branch
- Pull request events
- Every 15 minutes (schedule)
- Manual dispatch

**Features:**
- Detects remote changes before syncing
- Bidirectional synchronization
- Conflict detection and resolution
- Health check reporting
- Automated issue creation on failures

**Manual Trigger with Options:**
```bash
# Via GitHub CLI with parameters
gh workflow run bidirectional-sync.yml \
  -f target_branch=main \
  -f force_sync=true
```

---

## 📊 Monitoring & Logging

### Active Memory File: `.infinity/ACTIVE_MEMORY.md`

This file tracks:
- Last sync timestamp
- Total sync count
- Failed sync count
- Recent activity log
- Repository state

**View Current Status:**
```bash
cat .infinity/ACTIVE_MEMORY.md
```

### Sync Logs: `.infinity/sync.log`

Detailed logs of all sync operations:
```bash
# View recent logs
tail -n 50 .infinity/sync.log

# Search for errors
grep ERROR .infinity/sync.log

# Watch live
tail -f .infinity/sync.log
```

### Workflow Run Logs

Monitor GitHub Actions:
```bash
# List recent workflow runs
gh run list --workflow=auto-sync.yml

# View specific run logs
gh run view <run-id> --log
```

---

## 🔐 Security & Best Practices

### TAP Protocol Compliance

This sync system adheres to the **TAP Protocol** (Policy → Authority → Truth):

1. **Policy**: All sync operations require authentication
2. **Authority**: GitHub App (infinity-orchestrator) has write access
3. **Truth**: All operations are logged and auditable

### Protected Branches

Default protected branches (won't force push):
- `main`
- `master`
- `develop`

### Credentials

**SSH (Recommended)**:
```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"

# Add to GitHub
cat ~/.ssh/id_ed25519.pub
# Copy and add to: GitHub → Settings → SSH Keys
```

**Personal Access Token**:
```bash
# Create token at: GitHub → Settings → Developer settings → Personal access tokens
# Required scopes: repo, workflow

# Configure Git
git config --global credential.helper store
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

---

## 🛠️ Troubleshooting

### Common Issues

#### Issue: "Not a git repository"
**Solution**: Ensure you're running the script from the repository root directory.
```bash
cd /path/to/_ARCHIVE_2026
./scripts/sync-repository.sh
```

#### Issue: "Working tree has uncommitted changes"
**Solution**: Commit your changes or use `--force` flag.
```bash
git add .
git commit -m "Your commit message"
# OR
./scripts/sync-repository.sh --force
```

#### Issue: Merge Conflicts
**Solution 1**: Resolve manually
```bash
git status
# Edit conflicted files
git add .
git commit -m "Resolved conflicts"
./scripts/sync-repository.sh
```

**Solution 2**: Use force sync (uses remote version)
```bash
./scripts/sync-repository.sh --force
```

#### Issue: Permission Denied (Bash script)
**Solution**: Make script executable
```bash
chmod +x scripts/sync-repository.sh
```

#### Issue: GitHub Actions Failing
**Solution**: Check workflow logs
```bash
gh run list --workflow=auto-sync.yml
gh run view <run-id> --log
```

### Debug Mode

Enable verbose logging:

**PowerShell**:
```powershell
$VerbosePreference = "Continue"
.\scripts\Sync-Repository.ps1 -Verbose
```

**Bash**:
```bash
bash -x ./scripts/sync-repository.sh
```

---

## 📈 Advanced Usage

### Custom Sync Intervals

Edit `.github/workflows/auto-sync.yml`:

```yaml
schedule:
  - cron: '*/30 * * * *'  # Every 30 minutes
  - cron: '0 */6 * * *'   # Every 6 hours
  - cron: '0 0 * * *'     # Daily at midnight
```

### Integration with CI/CD

Add sync as a step in your workflow:

```yaml
- name: Sync Repository
  run: ./scripts/sync-repository.sh --mode bidirectional
```

### Webhook Integration

Configure GitHub webhooks to trigger sync on specific events:

1. Go to: Repository → Settings → Webhooks
2. Add webhook URL pointing to your sync endpoint
3. Select events: Push, Pull Request, etc.

### Multiple Remotes

Sync with multiple remotes:

```bash
# Add second remote
git remote add backup https://github.com/backup-org/repo.git

# Sync to both
./scripts/sync-repository.sh --remote origin
./scripts/sync-repository.sh --remote backup
```

---

## 🎓 Examples

### Example 1: Daily Development Workflow

```bash
# Morning: Start work
cd _ARCHIVE_2026
./scripts/sync-repository.sh --mode pull

# Make changes...
# ... edit files ...

# Evening: Push changes
git add .
git commit -m "Day's work complete"
./scripts/sync-repository.sh --mode push
```

### Example 2: Team Collaboration

```bash
# Before starting new feature
./scripts/sync-repository.sh --mode pull --branch develop

# Create feature branch
git checkout -b feature/new-feature

# Work on feature...
# ... code changes ...

# Sync main changes while working
./scripts/sync-repository.sh --mode pull --branch develop

# Merge and push
git checkout develop
git merge feature/new-feature
./scripts/sync-repository.sh --mode push
```

### Example 3: Emergency Hotfix

```bash
# Quick sync before hotfix
./scripts/sync-repository.sh --mode bidirectional --force

# Make urgent fix
# ... fix critical bug ...

# Immediate sync
git add .
git commit -m "HOTFIX: Critical bug"
./scripts/sync-repository.sh --mode push
```

---

## 📞 Support

### Documentation
- **Repository**: [Infinity-X-One-Systems/_ARCHIVE_2026](https://github.com/Infinity-X-One-Systems/_ARCHIVE_2026)
- **Issues**: [Report Issues](https://github.com/Infinity-X-One-Systems/_ARCHIVE_2026/issues)

### Commands Reference

| Command | PowerShell | Bash |
|---------|-----------|------|
| Basic Sync | `.\scripts\Sync-Repository.ps1` | `./scripts/sync-repository.sh` |
| Pull Only | `-Mode pull` | `--mode pull` |
| Push Only | `-Mode push` | `--mode push` |
| Force | `-Force` | `--force` |
| Dry Run | `-DryRun` | `--dry-run` |
| Help | `-Help` | `--help` |

---

## 🔄 Maintenance

### Update Sync Scripts

```bash
git pull origin main
chmod +x scripts/sync-repository.sh
```

### Clean Logs

```bash
# Archive old logs
mv .infinity/sync.log .infinity/sync.log.old

# Or remove
rm .infinity/sync.log
```

### Health Check

```bash
# Verify configuration
cat .infinity/sync-config.json | jq .

# Check active memory
cat .infinity/ACTIVE_MEMORY.md

# Test sync (dry run)
./scripts/sync-repository.sh --dry-run
```

---

## 📝 Version History

- **v1.0.0** (2026-02-18): Initial release
  - Bidirectional sync scripts (PowerShell & Bash)
  - Automated GitHub Actions workflows
  - Configuration management
  - Active memory tracking
  - Comprehensive documentation

---

## 🏆 Credits

**Developed by:** Overseer-Prime  
**Company:** Infinity X One Systems  
**License:** Proprietary  
**Status:** Production Ready ✅

---

*This sync system embodies the 110% Protocol: Zero Failure, Zero Tech Debt, Governance First.*
