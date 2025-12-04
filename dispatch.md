# dispatch.sh — Distributed Command Runner

`dispatch.sh` is a lightweight Bash utility for running commands across multiple nodes in your cluster.

**Cluster nodes:**

- `starbase-1` (manager)
- `orb1`
- `orb2`
- `orb3`

The script supports:

- Running commands on **all nodes**
- Running commands on a **specific node**
- **Parallel execution**
- Timestamped logging
- Safe Bash practices (`set -Eeuo pipefail`)

---

## Features

### Run a command on all nodes

```bash
./dispatch.sh "uptime"
```

### Run a command on a specific node

```bash
./dispatch.sh -n orb2 "docker ps -a"
```

### Run on all nodes in parallel

```bash
./dispatch.sh -p "hostname && sleep 2"
```

### Combine flags

```bash
./dispatch.sh -p -n orb1 "ls -l"
```

---

## Script Overview

### Node list

```bash
NODES=("starbase-1" "orb1" "orb2" "orb3")
```

Defines all nodes in the cluster.

### usage() function

Prints usage instructions if the user provides invalid flags or no command.

### Flags

| Flag      | Meaning                               |
|-----------|---------------------------------------|
| `-n NODE` | Run the command on a single node      |
| `-p`      | Run the command on all nodes in parallel |

---

## How it Works

### Logging

The `log()` function prints timestamped messages:

```bash
[12:30:01] Running on orb2: uptime
```

### SSH Execution

Each node is accessed via:

```bash
ssh "$node" "$CMD"
```

### Parallel Execution

When `-p` is used, each SSH call runs in the background:

```bash
run_on_node "$node" &
```

The script waits for all nodes to finish:

```bash
wait
```

---

## Requirements

- SSH keys set up for passwordless access
- Nodes must be reachable on your LAN or network
- Bash 4+ recommended

