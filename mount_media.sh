#!/usr/bin/env bash
set -Eeuo pipefail

log() { printf "[%s] %s\n" "$(date '+%H:%M:%S')" "$*"; }

# NFS server
SERVER="starbase-1"
EXPORT="/srv/media"
MOUNT="/mnt/media"

# All nodes including server
NODES=("starbase-1" "orb1" "orb2" "orb3")

for node in "${NODES[@]}"; do
    log "Mounting on $node"

    # Create mount dir
    ssh "$node" "sudo mkdir -p $MOUNT"

    # Mount command
    ssh "$node" "sudo mount -t nfs4 ${SERVER}:${EXPORT} $MOUNT" \
        && log "  ✅ Mounted" \
        || log "  ❌ Mount failed"

    echo
done

