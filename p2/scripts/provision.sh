#!/bin/bash
set -e

apt-get update

curl -sfL https://get.k3s.io | sh -

until kubectl get nodes >/dev/null 2>&1
do
    sleep 2
done

sudo nerdctl build \
    -t app1:latest \
    ./confs/app1

sudo nerdctl build \
    -t app2:latest \
    ./confs/app2

sudo nerdctl build \
    -t app3:latest \
    ./confs/app3

kubectl apply -f /home/vagrant/project/confs/app1
kubectl apply -f /home/vagrant/project/confs/app2
kubectl apply -f /home/vagrant/project/confs/app3
kubectl apply -f /home/vagrant/project/confs/ingress.yaml