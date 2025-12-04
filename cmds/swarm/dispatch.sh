#!/usr/bin/env bash
set -Eeuo pipefail

# -----------------------------
# Logging Setup
# -----------------------------

# Determine the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Repo root assumed two directories up from /cmds/swarm
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Logs directory relative to repo root
LOG_DIR="$REPO_ROOT/logs"
mkdir -p "$LOG_DIR"  # create if it doesn't exist

# Log file for current date
LOG_FILE="$LOG_DIR/$(date '+%Y-%m-%d').txt"

# Log function: prints to terminal and appends to log file
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
    echo "Usage: $0 [-n node] [-p] command..."
    echo "  -n node   Run command on only one node"
    echo "  -p        Run in parallel"
    exit 1
}

TARGET_NODE=""
PARALLEL=false

# -----------------------------
# Parse Options
# -----------------------------
while getopts "n:p" opt; do
    case "$opt" in
        n) TARGET_NODE="$OPTARG" ;;
        p) PARALLEL=true ;;
        *) usage ;;
    esac
done

# Remove parsed options so $@ contains only the command
shift $((OPTIND - 1))

# Ensure a command is provided
[[ $# -eq 0 ]] && usage
CMD="$*"

# -----------------------------
# Function to run on a node
# -----------------------------
run_on_node() {
    local node="$1"
    log "➡️  Running on $node: $CMD"

    if ssh "$node" "$CMD"; then
        log "   ✅ Success on $node"
    else
        log "   ❌ Failed on $node"
    fi
    echo
}

# -----------------------------
# Run Command
# -----------------------------
if [[ -n "$TARGET_NODE" ]]; then
    run_on_node "$TARGET_NODE"
    exit 0
fi

if $PARALLEL; then
    for node in "${NODES[@]}"; do
        run_on_node "$node" &
    done
    wait
else
    for node in "${NODES[@]}"; do
        run_on_node "$node"
    done
fi

