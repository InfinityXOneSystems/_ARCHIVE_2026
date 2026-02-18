<#
.SYNOPSIS
    Infinity X One Systems - Master Repository Sync Script
    
.DESCRIPTION
    Production-grade PowerShell script for bidirectional synchronization
    between remote and local repositories with advanced error handling,
    logging, and conflict resolution.
    
.PARAMETER Mode
    Sync mode: "pull" (remote → local), "push" (local → remote), "bidirectional" (both)
    
.PARAMETER Remote
    Remote name (default: "origin")
    
.PARAMETER Branch
    Branch to sync (default: current branch)
    
.PARAMETER ConfigPath
    Path to sync-config.json (default: .infinity/sync-config.json)
    
.PARAMETER Force
    Force sync even with conflicts (use with caution)
    
.PARAMETER DryRun
    Show what would be synced without actually syncing
    
.EXAMPLE
    .\Sync-Repository.ps1 -Mode bidirectional
    
.EXAMPLE
    .\Sync-Repository.ps1 -Mode pull -Branch main
    
.NOTES
    Version: 1.0.0
    Author: Overseer-Prime
    Company: Infinity X One Systems
#>

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet("pull", "push", "bidirectional")]
    [string]$Mode = "bidirectional",
    
    [Parameter()]
    [string]$Remote = "origin",
    
    [Parameter()]
    [string]$Branch = "",
    
    [Parameter()]
    [string]$ConfigPath = ".infinity/sync-config.json",
    
    [Parameter()]
    [switch]$Force,
    
    [Parameter()]
    [switch]$DryRun
)

# Set strict mode for production-grade error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Constants
$SCRIPT_VERSION = "1.0.0"
$TIMESTAMP = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$LOG_FILE = ".infinity/sync.log"

# Color codes for console output
$Colors = @{
    Success = "Green"
    Info    = "Cyan"
    Warning = "Yellow"
    Error   = "Red"
    Header  = "Magenta"
}

#region Helper Functions

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO", "SUCCESS", "WARNING", "ERROR")]
        [string]$Level = "INFO"
    )
    
    $logMessage = "[$TIMESTAMP] [$Level] $Message"
    
    # Console output with colors
    switch ($Level) {
        "SUCCESS" { Write-Host $Message -ForegroundColor $Colors.Success }
        "INFO"    { Write-Host $Message -ForegroundColor $Colors.Info }
        "WARNING" { Write-Host $Message -ForegroundColor $Colors.Warning }
        "ERROR"   { Write-Host $Message -ForegroundColor $Colors.Error }
    }
    
    # File logging
    if (Test-Path (Split-Path $LOG_FILE -Parent)) {
        Add-Content -Path $LOG_FILE -Value $logMessage -ErrorAction SilentlyContinue
    }
}

function Get-SyncConfig {
    if (Test-Path $ConfigPath) {
        try {
            $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
            Write-Log "✓ Configuration loaded from $ConfigPath" -Level SUCCESS
            return $config
        }
        catch {
            Write-Log "⚠ Failed to parse config file, using defaults" -Level WARNING
            return $null
        }
    }
    else {
        Write-Log "⚠ Config file not found at $ConfigPath, using defaults" -Level WARNING
        return $null
    }
}

function Test-GitRepository {
    if (-not (Test-Path ".git")) {
        Write-Log "✗ Not a git repository. Please run from repository root." -Level ERROR
        exit 1
    }
    Write-Log "✓ Git repository detected" -Level SUCCESS
}

function Get-CurrentBranch {
    try {
        $branch = git branch --show-current
        if ($LASTEXITCODE -eq 0) {
            return $branch.Trim()
        }
    }
    catch {
        Write-Log "✗ Failed to get current branch" -Level ERROR
        exit 1
    }
}

function Test-WorkingTreeClean {
    $status = git status --porcelain
    return [string]::IsNullOrEmpty($status)
}

function Invoke-GitPull {
    param([string]$RemoteName, [string]$BranchName)
    
    Write-Log "⬇ Pulling changes from $RemoteName/$BranchName..." -Level INFO
    
    if ($DryRun) {
        Write-Log "[DRY RUN] Would execute: git pull $RemoteName $BranchName" -Level INFO
        return $true
    }
    
    try {
        git pull $RemoteName $BranchName
        if ($LASTEXITCODE -eq 0) {
            Write-Log "✓ Pull completed successfully" -Level SUCCESS
            return $true
        }
        else {
            Write-Log "✗ Pull failed with exit code $LASTEXITCODE" -Level ERROR
            return $false
        }
    }
    catch {
        Write-Log "✗ Pull failed: $_" -Level ERROR
        return $false
    }
}

function Invoke-GitPush {
    param([string]$RemoteName, [string]$BranchName)
    
    Write-Log "⬆ Pushing changes to $RemoteName/$BranchName..." -Level INFO
    
    if ($DryRun) {
        Write-Log "[DRY RUN] Would execute: git push $RemoteName $BranchName" -Level INFO
        return $true
    }
    
    try {
        git push $RemoteName $BranchName
        if ($LASTEXITCODE -eq 0) {
            Write-Log "✓ Push completed successfully" -Level SUCCESS
            return $true
        }
        else {
            Write-Log "✗ Push failed with exit code $LASTEXITCODE" -Level ERROR
            return $false
        }
    }
    catch {
        Write-Log "✗ Push failed: $_" -Level ERROR
        return $false
    }
}

function Update-ActiveMemory {
    param([bool]$Success, [string]$Operation)
    
    $memoryFile = ".infinity/ACTIVE_MEMORY.md"
    if (Test-Path $memoryFile) {
        try {
            $content = Get-Content $memoryFile -Raw
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $statusIcon = if ($Success) { "✅" } else { "❌" }
            
            # Update last sync time
            $content = $content -replace "Last Sync:.*", "Last Sync:** $timestamp ($Operation) $statusIcon"
            
            # Add to activity log
            $logEntry = "`n$($content.Count + 1). **$timestamp:** $Operation - $(if($Success){'Success'}else{'Failed'})"
            $content = $content -replace "(\*This file is)", "$logEntry`n`n`$1"
            
            Set-Content -Path $memoryFile -Value $content -NoNewline
            Write-Log "✓ ACTIVE_MEMORY.md updated" -Level SUCCESS
        }
        catch {
            Write-Log "⚠ Failed to update ACTIVE_MEMORY.md: $_" -Level WARNING
        }
    }
}

#endregion

#region Main Script

function Main {
    Write-Host "`n╔══════════════════════════════════════════════════════════╗" -ForegroundColor $Colors.Header
    Write-Host "║   INFINITY X ONE SYSTEMS - MASTER SYNC PROTOCOL v$SCRIPT_VERSION   ║" -ForegroundColor $Colors.Header
    Write-Host "╚══════════════════════════════════════════════════════════╝`n" -ForegroundColor $Colors.Header
    
    # Pre-flight checks
    Test-GitRepository
    
    $config = Get-SyncConfig
    
    # Determine branch
    if ([string]::IsNullOrEmpty($Branch)) {
        $Branch = Get-CurrentBranch
        Write-Log "→ Using current branch: $Branch" -Level INFO
    }
    
    # Check for uncommitted changes
    if (-not (Test-WorkingTreeClean)) {
        Write-Log "⚠ Working tree has uncommitted changes" -Level WARNING
        if (-not $Force) {
            Write-Log "✗ Refusing to sync with uncommitted changes. Use -Force to override." -Level ERROR
            exit 1
        }
        Write-Log "⚠ Forcing sync despite uncommitted changes" -Level WARNING
    }
    
    # Fetch latest from remote
    Write-Log "🔄 Fetching from remote..." -Level INFO
    if (-not $DryRun) {
        git fetch $Remote --prune
    }
    
    $syncSuccess = $true
    
    # Execute sync based on mode
    switch ($Mode) {
        "pull" {
            Write-Log "📥 Mode: PULL (Remote → Local)" -Level INFO
            $syncSuccess = Invoke-GitPull -RemoteName $Remote -BranchName $Branch
        }
        "push" {
            Write-Log "📤 Mode: PUSH (Local → Remote)" -Level INFO
            $syncSuccess = Invoke-GitPush -RemoteName $Remote -BranchName $Branch
        }
        "bidirectional" {
            Write-Log "🔄 Mode: BIDIRECTIONAL (Remote ⟷ Local)" -Level INFO
            $pullSuccess = Invoke-GitPull -RemoteName $Remote -BranchName $Branch
            if ($pullSuccess) {
                $syncSuccess = Invoke-GitPush -RemoteName $Remote -BranchName $Branch
            }
            else {
                $syncSuccess = $false
            }
        }
    }
    
    # Update memory file
    Update-ActiveMemory -Success $syncSuccess -Operation $Mode.ToUpper()
    
    # Final status
    Write-Host "`n════════════════════════════════════════════════════════" -ForegroundColor $Colors.Header
    if ($syncSuccess) {
        Write-Log "✅ SYNC COMPLETE - All operations successful!" -Level SUCCESS
        exit 0
    }
    else {
        Write-Log "❌ SYNC FAILED - Review logs for details" -Level ERROR
        exit 1
    }
}

# Execute main function
try {
    Main
}
catch {
    Write-Log "💥 Fatal error: $_" -Level ERROR
    Write-Log "Stack trace: $($_.ScriptStackTrace)" -Level ERROR
    exit 1
}

#endregion
