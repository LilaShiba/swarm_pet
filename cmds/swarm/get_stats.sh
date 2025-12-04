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
# Destination directory for collected logs
# -----------------------------
DEST_DIR="$REPO_ROOT/collected_logs"
mkdir -p "$DEST_DIR"

# -----------------------------
# Collect logs from each node
# -----------------------------
for node in "${NODES[@]}"; do
    NODE_DEST="$DEST_DIR/$node"
    mkdir -p "$NODE_DEST"

    log "➡️ Collecting logs from $node"

    # Copy all files from node's log dir into node-specific directory
    if scp "$node:$LOG_DIR/"* "$NODE_DEST/" 2>/dev/null; then
        log "   ✅ Logs collected from $node"
    else
        log "   ⚠️ No logs found or failed to copy from $node"
    fi
done

log "✅ All logs collected to $DEST_DIR"
