# Part 1 — K3s and Vagrant

## Subject requirements (IV.1)

Spin up 2 VMs with Vagrant, using the latest stable version of a chosen
distribution. The subject strongly recommends bare-minimum resources
(1 CPU, 512–1024 MB RAM), but modern K3s (v1.36) does not boot reliably
within that budget, so resources here are bumped to **2 CPU / 2048 MB per
machine**. This is a deliberate deviation from the subject's suggestion for
the sake of stability — be ready to justify it during defense.

| Parameter   | Server (anmakaroS)   | ServerWorker (anmakaroSW) |
|-------------|------------------------|------------------------------|
| Hostname    | `anmakaroS`            | `anmakaroSW`                 |
| IP          | `192.168.56.110`       | `192.168.56.111`             |
| K3s role    | controller (server)    | agent                        |
| SSH         | passwordless            | passwordless                 |

K3s runs in two modes:
- **Server** — `k3s server`, bootstraps the control-plane and generates a
  join token.
- **ServerWorker** — `k3s agent`, joins the cluster using that token and
  becomes a worker node.

`kubectl` ships bundled with K3s as a symlink to the `k3s` binary — no
separate install needed.

## Architecture

```
┌─────────────────────┐        join token via         ┌──────────────────────┐
│   anmakaroS           │      shared /vagrant folder   │   anmakaroSW           │
│   192.168.56.110       │ ─────────────────────────────▶│   192.168.56.111       │
│   K3s server             │                            │   K3s agent              │
│   (control-plane)        │◀─────────────────────────────│   (worker node)          │
└─────────────────────┘        joins via :6443           └──────────────────────┘
```

The join token is never copied by hand — both VMs mount the same project
folder at `/vagrant` (Vagrant's default synced folder), so `server.sh`
writes the token there and `worker.sh` waits for that file and reads it.

The network interface used by K3s (`--flannel-iface`) is auto-detected by
IP instead of being hardcoded as `eth1`, since modern distros use
predictable interface names (`enp0s8`, etc.) — the subject itself calls
this out explicitly.

## Files

```
p1/
├── Vagrantfile
├── README.md
└── scripts/
    ├── server.sh   # installs curl, installs K3s in server mode, publishes the token
    └── worker.sh   # installs curl, waits for the token, installs K3s in agent mode
```

## Usage

```bash
cd p1
vagrant up
```

First boot takes a few minutes (box download, apt update, K3s download).
The server comes up first; the worker waits for its token and joins after.

## Verification

```bash
vagrant ssh anmakaroS
sudo kubectl get nodes -o wide
```

Expected: both nodes `Ready`.

```
NAME         STATUS   ROLES           VERSION
anmakaros    Ready    control-plane   v1.36.2+k3s1
anmakarosw   Ready    <none>          v1.36.2+k3s1
```

Passwordless SSH is confirmed by `vagrant ssh anmakaroS` /
`vagrant ssh anmakaroSW` connecting instantly with no password prompt
(Vagrant generates and injects the keypair on first `vagrant up`).

## Vagrant command cheat sheet

### Lifecycle

| Command | What it does |
|---|---|
| `vagrant up` | Create and/or start all machines defined in the Vagrantfile |
| `vagrant up <name>` | Start only one machine, e.g. `vagrant up anmakaroS` |
| `vagrant status` | Show current state of all machines (running/poweroff/not created) |
| `vagrant halt` | Gracefully shut down all machines (ACPI), disk state is preserved |
| `vagrant halt <name>` | Shut down a specific machine |
| `vagrant halt -f` | Force shutdown if ACPI doesn't respond |
| `vagrant reload` | Restart a machine (halt + up), applies Vagrantfile changes without recreating it |
| `vagrant reload --provision` | Same, plus reruns the provisioning scripts |
| `vagrant suspend` | Save state and freeze the machine, faster than halt/up |
| `vagrant resume` | Wake up after suspend |
| `vagrant destroy` | Fully delete a machine (disk + config) — data inside is lost |
| `vagrant destroy -f` | Same, without confirmation prompt |

### Connecting & debugging

| Command | What it does |
|---|---|
| `vagrant ssh <name>` | SSH into a machine |
| `vagrant ssh-config <name>` | Show SSH connection details (port, key, etc.) |
| `vagrant provision` | Rerun provisioning scripts without recreating the machine |
| `vagrant provision <name>` | Same, for a specific machine |
| `vagrant global-status` | List all Vagrant machines on the host, across projects |
| `vagrant global-status --prune` | Same, plus remove stale entries |

### Box management

| Command | What it does |
|---|---|
| `vagrant box list` | List downloaded boxes |
| `vagrant box add <name>` | Manually download a box |
| `vagrant box update` | Update a box to its latest version |
| `vagrant box remove <name>` | Remove a box from the local cache |

### Misc

| Command | What it does |
|---|---|
| `vagrant validate` | Check Vagrantfile syntax without starting machines |
| `vagrant snapshot save <name> <tag>` | Save a machine's state snapshot |
| `vagrant snapshot restore <name> <tag>` | Roll back to a snapshot |
| `vagrant port <name>` | Show forwarded ports |

## End-of-day routine

```bash
vagrant halt      # safely shut down both VMs, nothing is lost
vagrant status    # confirm both are poweroff
```

Next day, just `vagrant up` — everything comes back in the same state.

⚠️ **Never run `vagrant destroy` unless you want to start from scratch** —
it deletes the machine's virtual disk entirely, not just powers it off.
