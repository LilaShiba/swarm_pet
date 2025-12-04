#!/usr/bin/env bash
set -Eeuo pipefail

# -----------------------------
# Logging Setup
# -----------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOG_DIR="$REPO_ROOT/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/$(date '+%Y-%m-%d').txt"

log() {
    local timestamp
    timestamp="$(date '+%H:%M:%S')"
    printf "[%s] %s\n" "$timestamp" "$*" | tee -a "$LOG_FILE"
}

# -----------------------------
# Cluster Nodes
# -----------------------------
NODES=("starbase-1" "orb1" "orb2" "orb3")

# -----------------------------
# Usage
# -----------------------------
usage() {
    echo "Usage: $0 <local_file> <remote_path>"
    exit 1
}

[[ $# -ne 2 ]] && usage
LOCAL_FILE="$1"
REMOTE_PATH="$2"

# -----------------------------
# Upload to Nodes
# -----------------------------
for node in "${NODES[@]}"; do
    log "➡️ Uploading $LOCAL_FILE to $node:$REMOTE_PATH"

    NODE_LOG_DIR="$LOG_DIR/$node"
    mkdir -p "$NODE_LOG_DIR"

    if scp "$LOCAL_FILE" "$node:$REMOTE_PATH"; then
        log "   ✅ Success on $node"
    else
        log "   ❌ Failed on $node"
    fi
done
