# _ARCHIVE_2026

## 🔄 Master Sync System

This repository includes a **production-grade master sync system** for maintaining perfect synchronization between remote and local repositories.

### Quick Start

**Windows (PowerShell)**:
```powershell
.\scripts\Sync-Repository.ps1 -Mode bidirectional
```

**macOS/Linux (Bash)**:
```bash
./scripts/sync-repository.sh --mode bidirectional
```

### Features
- ✅ **Bidirectional Sync**: Seamlessly sync changes in both directions (Remote ⟷ Local)
- ✅ **Live Persistent Sync**: Automated workflows ensure continuous synchronization
- ✅ **Cross-Platform**: Works on Windows (PowerShell), macOS, and Linux (Bash)
- ✅ **GitHub Actions**: Automated hourly sync + 15-minute bidirectional checks
- ✅ **Conflict Resolution**: Intelligent handling of merge conflicts
- ✅ **Status Tracking**: Real-time sync status via `.infinity/ACTIVE_MEMORY.md`

### Documentation

📖 **Complete Guide**: [`.infinity/SYNC_GUIDE.md`](.infinity/SYNC_GUIDE.md)

### Structure

```
_ARCHIVE_2026/
├── .github/workflows/       # Automated sync workflows
│   ├── auto-sync.yml       # Hourly automated sync
│   └── bidirectional-sync.yml  # Live persistent sync (every 15 min)
├── .infinity/              # Configuration & tracking
│   ├── ACTIVE_MEMORY.md    # Current repository state
│   ├── sync-config.json    # Sync configuration
│   └── SYNC_GUIDE.md       # Complete documentation
└── scripts/                # Manual sync scripts
    ├── Sync-Repository.ps1 # PowerShell (Windows)
    └── sync-repository.sh  # Bash (Unix/Linux/Mac)
```

### Automated Workflows

#### Auto Sync (Hourly)
- Runs every hour at :00
- Pulls latest changes
- Pushes local changes
- Updates sync status

#### Bidirectional Sync (Every 15 minutes)
- Monitors for remote changes
- Performs bidirectional sync
- Resolves conflicts automatically
- Creates health reports

### Manual Sync Commands

| Action | PowerShell | Bash |
|--------|-----------|------|
| Bidirectional | `.\scripts\Sync-Repository.ps1` | `./scripts/sync-repository.sh` |
| Pull Only | `-Mode pull` | `--mode pull` |
| Push Only | `-Mode push` | `--mode push` |
| Force Sync | `-Force` | `--force` |
| Dry Run | `-DryRun` | `--dry-run` |

### Configuration

Edit `.infinity/sync-config.json` to customize:
- Sync mode (pull, push, bidirectional)
- Conflict resolution strategy
- Protected branches
- Excluded paths
- Schedule frequency

---

**Version**: 1.0.0  
**Status**: ✅ Production Ready  
**Developed by**: Overseer-Prime @ Infinity X One Systems