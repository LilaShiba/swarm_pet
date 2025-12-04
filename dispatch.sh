#!/usr/bin/env bash
set -Eeuo pipefail

log() { printf "[%s] %s\n" "$(date '+%H:%M:%S')" "$*"; }

# Your cluster nodes
NODES=("starbase-1" "orb1" "orb2" "orb3")

usage() {
    echo "Usage: $0 [-n node] [-p] command..."
    echo "  -n node   Run command on only one node"
    echo "  -p        Run in parallel"
    exit 1
}

TARGET_NODE=""
PARALLEL=false

# Parse flags
while getopts "n:p" opt; do
    case "$opt" in
        n) TARGET_NODE="$OPTARG" ;;
        p) PARALLEL=true ;;
        *) usage ;;
    esac
done

# Remove parsed options so $@ contains only the command
shift $((OPTIND - 1))

# Command must be provided
[[ $# -eq 0 ]] && usage

CMD="$*"

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

# If a single node was specified
if [[ -n "$TARGET_NODE" ]]; then
    run_on_node "$TARGET_NODE"
    exit 0
fi

# Otherwise run on all nodes
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

