#!/bin/bash
set -e

sudo nerdctl --namespace k8s.io images

if ! sudo nerdctl image inspect app1:latest >/dev/null 2>&1; then
    sudo nerdctl build -t app1:latest ./confs/app1
fi

if ! sudo nerdctl image inspect app2:latest >/dev/null 2>&1; then
    sudo nerdctl build -t app2:latest ./confs/app2
fi

if ! sudo nerdctl image inspect app3:latest >/dev/null 2>&1; then
    sudo nerdctl build -t app3:latest ./confs/app3
fi

sudo nerdctl images