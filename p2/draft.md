Что надо поменять:

---

### 1. `build.sh` должен ВСЕГДА собирать свежие образы

Не:

```bash
if image exists -> skip
```

А:

```bash
for app in app1 app2 app3; do
    echo "Building ${app}..."
    sudo -E nerdctl build \
        --no-cache \
        -t "${app}:latest" \
        "confs/${app}"
done
```

Иначе `latest` будет вечным источником старых образов.

---

### 2. В deployment.yaml всех приложений добавить

Например app2:

```yaml
containers:
- name: app2
  image: app2:latest
  imagePullPolicy: Never
```

То же для app1 и app3.

Почему:

k3s не должен искать образ в Docker Hub. Он должен брать локальный образ из containerd.

---

### 3. После сборки нужно заставить Kubernetes взять новые образы

В `deploy.sh` после `kubectl apply`:

```bash
kubectl delete pod -l app=app1 --ignore-not-found
kubectl delete pod -l app=app2 --ignore-not-found
kubectl delete pod -l app=app3 --ignore-not-found
```

Тогда deployment создаст новые pod'ы с новыми image.

---

### 4. Самое важное: сделать запуск идемпотентным

Идеальный порядок:

```
vagrant up

 ├── install k3s
 ├── install nerdctl
 ├── build app1
 ├── build app2
 ├── build app3
 ├── wait for traefik
 ├── kubectl apply deployments
 ├── kubectl apply services
 ├── kubectl apply ingress
 └── finish
```

После этого:

```bash
curl -H "Host: app1.com" http://192.168.56.110
curl -H "Host: app2.com" http://192.168.56.110
curl -H "Host: app3.com" http://192.168.56.110
```

работают сразу.

---

Но сейчас у тебя есть ещё один важный баг: **ты проверяешь через браузер**, а браузер может кэшировать nginx-страницу. Для финальной проверки после изменений используй только:

```bash
curl -H "Host: app1.com" http://192.168.56.110
curl -H "Host: app2.com" http://192.168.56.110
curl -H "Host: app3.com" http://192.168.56.110
```

---

То есть итоговые изменения для проекта:

1. убрать условие `if image exists`;
2. добавить `imagePullPolicy: Never`;
3. пересоздавать pod после новой сборки;
4. оставить всё в provisioner'ах Vagrant.

После этого `vagrant up` будет единственной командой.
