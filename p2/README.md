# Inception of Things — Part 2

## K3s and Three Simple Applications

This part of the **Inception of Things** project sets up a single virtual machine running K3s in server mode and deploys three simple web applications.

The applications are exposed through a Kubernetes Ingress using different HTTP `Host` values:

| Host           | Application |
| -------------- | ----------- |
| `app1.com`     | App 1       |
| `app2.com`     | App 2       |
| Any other host | App 3       |

Application 2 runs with **3 replicas**, as required by the subject.

The VM is accessible through the dedicated IP:

```text
192.168.56.110
```

---

## Requirements

The project uses:

* Vagrant
* VirtualBox
* Ubuntu Jammy (`ubuntu/jammy64`)
* K3s
* Kubernetes
* Traefik Ingress
* nerdctl
* BuildKit
* nginx

The complete environment is created inside the Vagrant virtual machine.

---

## Directory Structure

The Part 2 directory is organized as follows:

```text
p2/
├── Vagrantfile
├── README.md
├── scripts/
│   ├── install_k3s.sh
│   ├── install_nerdctl.sh
│   ├── build.sh
│   └── deploy.sh
│
└── confs/
    ├── app1/
    │   ├── Dockerfile
    │   ├── index.html
    │   ├── deployment.yaml
    │   └── service.yaml
    │
    ├── app2/
    │   ├── Dockerfile
    │   ├── index.html
    │   ├── deployment.yaml
    │   └── service.yaml
    │
    ├── app3/
    │   ├── Dockerfile
    │   ├── index.html
    │   ├── deployment.yaml
    │   └── service.yaml
    │
    └── ingress.yaml
```

The subject specifies that configuration files should be organized in `confs` and installation/helper scripts in `scripts`.

---

# Architecture

The setup consists of one Vagrant VM:

```text
                         Host Machine
                              |
                              |
                    192.168.56.110
                              |
                    +---------v---------+
                    |                   |
                    |    K3s Server     |
                    |                   |
                    |    Traefik        |
                    |     Ingress       |
                    |        |          |
                    +--------+----------+
                             |
              +--------------+--------------+
              |              |              |
              v              v              v
          app1-service   app2-service   app3-service
              |              |              |
              v              v              v
           App 1         App 2 x3        App 3
```

Kubernetes Services provide stable internal endpoints for the applications, while Traefik performs HTTP host-based routing.

The Part 2 requirement is specifically that requests to `192.168.56.110` are routed according to the `Host`: `app1.com` must reach App 1, `app2.com` must reach App 2, and App 3 must be selected otherwise.

---

# Vagrant VM

The VM is configured with:

```ruby
config.vm.box = "ubuntu/jammy64"
server.vm.hostname = "pkosturaS"
server.vm.network "private_network", ip: "192.168.56.110"
```

The VM uses:

```text
RAM: 2048 MB
CPU: 2
IP: 192.168.56.110
Hostname: pkosturaS
```

The project directory on the host is synchronized to:

```text
/home/vagrant/project
```

The VM is automatically provisioned using four scripts:

```text
install_k3s.sh
install_nerdctl.sh
build.sh
deploy.sh
```

---

# Starting the Environment

From the `p2` directory:

```bash
vagrant up
```

Vagrant will:

1. Create the Ubuntu VM.
2. Configure the hostname and private IP.
3. Install K3s.
4. Wait for the K3s containerd runtime.
5. Install nerdctl and BuildKit.
6. Build the three application images.
7. Deploy the Kubernetes resources.

After provisioning, connect to the VM:

```bash
vagrant ssh
```

Check K3s:

```bash
sudo systemctl status k3s
```

Check the Kubernetes nodes:

```bash
sudo kubectl get nodes
```

The node should be in the `Ready` state.

---

# Container Images

Each application is a small nginx image.

For example, App 3 uses:

```dockerfile
FROM nginx:stable-alpine

COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80
```

Each application has its own `index.html`.

For example:

```text
App 1 -> Hello from App 1!
App 2 -> Hello from App 2!
App 3 -> Hello from App 3!
```

The images are built locally inside the VM using **nerdctl**.

K3s uses containerd as its container runtime, so nerdctl is configured to use the K3s containerd socket and the `k8s.io` namespace.

The relevant containerd socket is:

```text
/run/k3s/containerd/containerd.sock
```

Images can be inspected with:

```bash
sudo nerdctl \
    --address /run/k3s/containerd/containerd.sock \
    --namespace k8s.io \
    images
```

Expected images:

```text
app1:latest
app2:latest
app3:latest
```

---

# Kubernetes Deployments

Each application has a Deployment.

App 3, for example:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app3
  labels:
    app: app3
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app3
  template:
    metadata:
      labels:
        app: app3
    spec:
      containers:
        - name: app3
          image: app3:latest
          imagePullPolicy: Never
          ports:
            - containerPort: 80
```

The important points are:

* Each application has its own label.
* Each Deployment selects its own pods.
* The local images use `imagePullPolicy: Never`.
* App 1 has one replica.
* App 2 has three replicas.
* App 3 has one replica.

The subject explicitly requires application 2 to have three replicas.

Check the Deployments with:

```bash
sudo kubectl get deployments
```

Expected result:

```text
NAME   READY   UP-TO-DATE   AVAILABLE
app1   1/1     1            1
app2   3/3     3            3
app3   1/1     1            1
```

Check the pods:

```bash
sudo kubectl get pods -o wide
```

---

# Kubernetes Services

Each Deployment has a corresponding ClusterIP Service:

```text
app1-service
app2-service
app3-service
```

The Services select their applications using labels:

```text
app=app1
app=app2
app=app3
```

For example, App 2's Service selects:

```yaml
selector:
  app: app2
```

This is important because App 2 has three replicas. Kubernetes sends requests to the pods selected by the Service.

Check the Services:

```bash
sudo kubectl get services
```

Check their endpoints:

```bash
sudo kubectl get endpoints
```

App 2 should have three pod endpoints.

---

# Ingress

K3s provides Traefik as the Ingress controller.

The Ingress is configured with three routing rules.

## App 1

Requests containing:

```text
Host: app1.com
```

are sent to:

```text
app1-service:80
```

## App 2

Requests containing:

```text
Host: app2.com
```

are sent to:

```text
app2-service:80
```

## App 3

The final rule does not specify a host:

```yaml
- http:
    paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app3-service
            port:
              number: 80
```

Therefore App 3 acts as the default application for hosts that don't match `app1.com` or `app2.com`.

This matches the subject requirement that App 3 is selected by default.

Check the Ingress:

```bash
sudo kubectl get ingress
```

For more details:

```bash
sudo kubectl describe ingress apps-ingress
```

The expected routing is:

```text
app1.com -> app1-service
app2.com -> app2-service
*        -> app3-service
```

The subject specifically notes that the Ingress is expected to be shown to evaluators during the defense.

---

# Configuring the Host Machine

The host machine must resolve the application domain names to the VM.

Edit `/etc/hosts` on the **host machine**, not inside the VM:

```bash
sudo nano /etc/hosts
```

Add:

```text
192.168.56.110 app1.com
192.168.56.110 app2.com
192.168.56.110 app3.com
```

The domain names are only local development names. They do not require public DNS.

After this configuration:

```text
http://app1.com
```

goes to:

```text
192.168.56.110
```

with:

```text
Host: app1.com
```

Traefik then routes the request to App 1.

---

# Testing with curl

Test App 1:

```bash
curl http://app1.com
```

Expected:

```text
Hello from App 1!
```

Test App 2:

```bash
curl http://app2.com
```

Expected:

```text
Hello from App 2!
```

Test App 3:

```bash
curl http://app3.com
```

Expected:

```text
Hello from App 3!
```

You can also test the default rule with another hostname:

```bash
curl -H "Host: example.com" http://192.168.56.110
```

Expected:

```text
Hello from App 3!
```

The important point is that the HTTP `Host` determines which Ingress rule is selected.

---

# Testing the Services Directly

Ingress can be bypassed when debugging.

For example:

```bash
sudo kubectl port-forward svc/app1-service 8081:80
```

Then:

```bash
curl http://localhost:8081
```

For App 2:

```bash
sudo kubectl port-forward svc/app2-service 8082:80
```

Then:

```bash
curl http://localhost:8082
```

For App 3:

```bash
sudo kubectl port-forward svc/app3-service 8083:80
```

Then:

```bash
curl http://localhost:8083
```

This is useful for determining whether a problem is inside the application/Service or in the Ingress configuration.

---

# Useful Kubernetes Commands

Check everything:

```bash
sudo kubectl get all
```

Check pods:

```bash
sudo kubectl get pods -o wide
```

Check Deployments:

```bash
sudo kubectl get deployments
```

Check Services:

```bash
sudo kubectl get services
```

Check Ingress:

```bash
sudo kubectl get ingress
```

Describe the Ingress:

```bash
sudo kubectl describe ingress apps-ingress
```

Check application logs:

```bash
sudo kubectl logs deployment/app1
sudo kubectl logs deployment/app2
sudo kubectl logs deployment/app3
```

Enter an application pod:

```bash
sudo kubectl exec -it deployment/app1 -- sh
```

Check the application HTML directly:

```bash
sudo kubectl exec deployment/app1 -- \
    cat /usr/share/nginx/html/index.html
```

---

# Rebuilding an Application

When developing the applications, changes to `index.html` or the Dockerfile require rebuilding the image.

Build App 1:

```bash
sudo nerdctl \
    --address /run/k3s/containerd/containerd.sock \
    --namespace k8s.io \
    build \
    -t app1:latest \
    /home/vagrant/project/confs/app1
```

Build App 2:

```bash
sudo nerdctl \
    --address /run/k3s/containerd/containerd.sock \
    --namespace k8s.io \
    build \
    -t app2:latest \
    /home/vagrant/project/confs/app2
```

Build App 3:

```bash
sudo nerdctl \
    --address /run/k3s/containerd/containerd.sock \
    --namespace k8s.io \
    build \
    -t app3:latest \
    /home/vagrant/project/confs/app3
```

After rebuilding an image, restart the corresponding Deployment:

```bash
sudo kubectl rollout restart deployment app1
sudo kubectl rollout restart deployment app2
sudo kubectl rollout restart deployment app3
```

During development, make sure the image is actually rebuilt when application files change. Because the images use the `latest` tag and are local images, stale images can otherwise make it appear that Kubernetes is ignoring a change.

---

# Reprovisioning

To run the provisioning scripts again:

```bash
vagrant provision
```

If the VM is in a bad or inconsistent state, destroy and recreate it:

```bash
vagrant destroy -f
vagrant up
```

This recreates the VM and runs the provisioning process from the beginning.

---

# Stopping the Project

To stop the VM without destroying it:

```bash
vagrant halt
```

Start it again with:

```bash
vagrant up
```

To completely remove the VM:

```bash
vagrant destroy -f
```
