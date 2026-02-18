#!/usr/bin/env bash

################################################################################
# Infinity X One Systems - Master Repository Sync Script
#
# Production-grade Bash script for bidirectional synchronization between
# remote and local repositories with advanced error handling, logging,
# and conflict resolution.
#
# Usage:
#   ./sync-repository.sh [OPTIONS]
#
# Options:
#   -m, --mode MODE        Sync mode: pull, push, bidirectional (default: bidirectional)
#   -r, --remote NAME      Remote name (default: origin)
#   -b, --branch NAME      Branch to sync (default: current branch)
#   -c, --config PATH      Path to sync-config.json
#   -f, --force            Force sync even with conflicts
#   -d, --dry-run          Show what would be synced without syncing
#   -h, --help             Show this help message
#
# Version: 1.0.0
# Author: Overseer-Prime
# Company: Infinity X One Systems
################################################################################

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Constants
readonly SCRIPT_VERSION="1.0.0"
readonly TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"
readonly LOG_FILE=".infinity/sync.log"

# Default values
MODE="bidirectional"
REMOTE="origin"
BRANCH=""
CONFIG_PATH=".infinity/sync-config.json"
FORCE=false
DRY_RUN=false

# Color codes
readonly COLOR_RESET='\033[0m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_MAGENTA='\033[0;35m'
readonly COLOR_CYAN='\033[0;36m'

################################################################################
# Helper Functions
################################################################################

log() {
    local level="$1"
    shift
    local message="$*"
    local color=""
    
    case "$level" in
        SUCCESS) color="$COLOR_GREEN" ;;
        INFO)    color="$COLOR_CYAN" ;;
        WARNING) color="$COLOR_YELLOW" ;;
        ERROR)   color="$COLOR_RED" ;;
    esac
    
    # Console output with colors
    echo -e "${color}${message}${COLOR_RESET}"
    
    # File logging
    if [[ -d "$(dirname "$LOG_FILE")" ]]; then
        echo "[$TIMESTAMP] [$level] $message" >> "$LOG_FILE" 2>/dev/null || true
    fi
}

print_header() {
    echo -e "${COLOR_MAGENTA}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║   INFINITY X ONE SYSTEMS - MASTER SYNC PROTOCOL v$SCRIPT_VERSION   ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${COLOR_RESET}"
}

show_help() {
    cat << EOF
Infinity X One Systems - Master Repository Sync Script v$SCRIPT_VERSION

Usage: $0 [OPTIONS]

Options:
  -m, --mode MODE        Sync mode: pull, push, bidirectional (default: bidirectional)
  -r, --remote NAME      Remote name (default: origin)
  -b, --branch NAME      Branch to sync (default: current branch)
  -c, --config PATH      Path to sync-config.json (default: .infinity/sync-config.json)
  -f, --force            Force sync even with conflicts
  -d, --dry-run          Show what would be synced without actually syncing
  -h, --help             Show this help message

Examples:
  $0 -m bidirectional
  $0 -m pull -b main
  $0 -m push --dry-run

EOF
}

check_git_repo() {
    if [[ ! -d ".git" ]]; then
        log ERROR "✗ Not a git repository. Please run from repository root."
        exit 1
    fi
    log SUCCESS "✓ Git repository detected"
}

get_current_branch() {
    git branch --show-current
}

is_working_tree_clean() {
    [[ -z "$(git status --porcelain)" ]]
}

load_config() {
    if [[ -f "$CONFIG_PATH" ]]; then
        log SUCCESS "✓ Configuration loaded from $CONFIG_PATH"
        return 0
    else
        log WARNING "⚠ Config file not found at $CONFIG_PATH, using defaults"
        return 1
    fi
}

git_pull() {
    local remote_name="$1"
    local branch_name="$2"
    
    log INFO "⬇ Pulling changes from $remote_name/$branch_name..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log INFO "[DRY RUN] Would execute: git pull $remote_name $branch_name"
        return 0
    fi
    
    if git pull "$remote_name" "$branch_name"; then
        log SUCCESS "✓ Pull completed successfully"
        return 0
    else
        log ERROR "✗ Pull failed with exit code $?"
        return 1
    fi
}

git_push() {
    local remote_name="$1"
    local branch_name="$2"
    
    log INFO "⬆ Pushing changes to $remote_name/$branch_name..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log INFO "[DRY RUN] Would execute: git push $remote_name $branch_name"
        return 0
    fi
    
    if git push "$remote_name" "$branch_name"; then
        log SUCCESS "✓ Push completed successfully"
        return 0
    else
        log ERROR "✗ Push failed with exit code $?"
        return 1
    fi
}

update_active_memory() {
    local success="$1"
    local operation="$2"
    local memory_file=".infinity/ACTIVE_MEMORY.md"
    
    if [[ ! -f "$memory_file" ]]; then
        return 0
    fi
    
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    local status_icon
    [[ "$success" == "true" ]] && status_icon="✅" || status_icon="❌"
    
    # Update last sync time
    sed -i.bak "s/Last Sync:.*/Last Sync:** $timestamp ($operation) $status_icon/" "$memory_file" 2>/dev/null || true
    
    # Add to activity log (insert before closing note)
    local log_entry="\n$(($(grep -c "^[0-9]" "$memory_file" 2>/dev/null || echo 0) + 1)). **$timestamp:** $operation - $([ "$success" == "true" ] && echo "Success" || echo "Failed")"
    sed -i.bak "s|\(\*This file is\)|$log_entry\n\n\1|" "$memory_file" 2>/dev/null || true
    
    # Clean up backup file
    rm -f "${memory_file}.bak"
    
    log SUCCESS "✓ ACTIVE_MEMORY.md updated"
}

################################################################################
# Argument Parsing
################################################################################

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -m|--mode)
                MODE="$2"
                if [[ ! "$MODE" =~ ^(pull|push|bidirectional)$ ]]; then
                    log ERROR "Invalid mode: $MODE"
                    exit 1
                fi
                shift 2
                ;;
            -r|--remote)
                REMOTE="$2"
                shift 2
                ;;
            -b|--branch)
                BRANCH="$2"
                shift 2
                ;;
            -c|--config)
                CONFIG_PATH="$2"
                shift 2
                ;;
            -f|--force)
                FORCE=true
                shift
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log ERROR "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

################################################################################
# Main Script
################################################################################

main() {
    print_header
    
    # Pre-flight checks
    check_git_repo
    load_config || true
    
    # Determine branch
    if [[ -z "$BRANCH" ]]; then
        BRANCH="$(get_current_branch)"
        log INFO "→ Using current branch: $BRANCH"
    fi
    
    # Check for uncommitted changes
    if ! is_working_tree_clean; then
        log WARNING "⚠ Working tree has uncommitted changes"
        if [[ "$FORCE" != "true" ]]; then
            log ERROR "✗ Refusing to sync with uncommitted changes. Use --force to override."
            exit 1
        fi
        log WARNING "⚠ Forcing sync despite uncommitted changes"
    fi
    
    # Fetch latest from remote
    log INFO "🔄 Fetching from remote..."
    if [[ "$DRY_RUN" != "true" ]]; then
        git fetch "$REMOTE" --prune || true
    fi
    
    local sync_success=true
    
    # Execute sync based on mode
    case "$MODE" in
        pull)
            log INFO "📥 Mode: PULL (Remote → Local)"
            git_pull "$REMOTE" "$BRANCH" || sync_success=false
            ;;
        push)
            log INFO "📤 Mode: PUSH (Local → Remote)"
            git_push "$REMOTE" "$BRANCH" || sync_success=false
            ;;
        bidirectional)
            log INFO "🔄 Mode: BIDIRECTIONAL (Remote ⟷ Local)"
            if git_pull "$REMOTE" "$BRANCH"; then
                git_push "$REMOTE" "$BRANCH" || sync_success=false
            else
                sync_success=false
            fi
            ;;
    esac
    
    # Update memory file
    update_active_memory "$sync_success" "${MODE^^}"
    
    # Final status
    echo -e "${COLOR_MAGENTA}════════════════════════════════════════════════════════${COLOR_RESET}"
    if [[ "$sync_success" == "true" ]]; then
        log SUCCESS "✅ SYNC COMPLETE - All operations successful!"
        exit 0
    else
        log ERROR "❌ SYNC FAILED - Review logs for details"
        exit 1
    fi
}

# Parse arguments and execute main
parse_args "$@"
main
