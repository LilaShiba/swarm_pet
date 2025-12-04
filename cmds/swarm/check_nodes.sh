#!/usr/bin/env bash
set -Eeuo pipefail

NODES=("starbase-1" "orb1" "orb2" "orb3")

for node in "${NODES[@]}"; do
    log "Checking $node"
    
    if ping -c1 -W1 "$node" &>/dev/null; then
        log "  ✅ Ping OK"
    else
        log "  ❌ Ping FAIL"
        continue
    fi

    if ssh "$node" "docker node ls" &>/dev/null; then
        log "  🐳 Docker OK"
    else
        log "  ❌ Docker FAIL"
    fi

    echo
done

