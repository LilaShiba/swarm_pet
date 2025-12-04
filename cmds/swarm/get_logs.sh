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
# Collect stats
# -----------------------------
for node in "${NODES[@]}"; do
    log "➡️ Gathering stats from $node"

    NODE_LOG_DIR="$LOG_DIR/$node"
    mkdir -p "$NODE_LOG_DIR"

    STATS=$(ssh "$node" "echo CPU: \$(top -bn1 | grep 'Cpu(s)' | awk '{print \$2 + \$4}')% | \
memory: \$(free -m | awk '/Mem:/ {printf(\"%.1f%%\", \$3/\$2*100)}') | \
disk: \$(df -h / | awk 'NR==2 {print \$5}')")

    log "   📊 $node stats -> $STATS"
done
