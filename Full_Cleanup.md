# Full Cleanup

> **Warning:** This cleanup is destructive. It removes the project's virtual machines, all installed Vagrant boxes for the current user, Docker resources, Kubernetes/k3d configuration, and the project directory.

## 1. Run the cleanup script

From the repository root:

```bash
./scripts/cleanup.sh
```

The script removes:

* Vagrant virtual machines created by `p1` and `p2`
* `.vagrant` directories
* the `mmakagonS` k3d cluster
* unused Docker resources, images, containers, networks and volumes
* **all Vagrant boxes installed for the current user**
* `~/.kube`
* `~/.config/argocd`
* `~/.local/share/k3d`

Wait until the script prints:

```text
Cleanup finished.
```

## 2. Remove the repository

After the cleanup script has finished, go to the parent directory:

```bash
cd ..
```

Remove the repository:

```bash
rm -rf IoT
```

## 3. Verify the cleanup

Check that no Vagrant boxes remain:

```bash
vagrant box list
```

The command should return no boxes.

Check that no project VMs remain:

```bash
VBoxManage list vms
```

Check that no k3d clusters remain:

```bash
k3d cluster list
```

The project cluster should no longer be present.

## Complete cleanup

The complete procedure is therefore simply:

```bash
cd /home/osboxes/IoT
./scripts/cleanup.sh
cd ..
rm -rf IoT
```

After these commands, the project and the resources created by it are removed from the machine.