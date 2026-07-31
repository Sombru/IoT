apiVersion: apps/v1
kind: Deployment
metadata:
  name: mmakagon-playground
  namespace: dev
  labels:
    app: playground
spec:
  replicas: 1
  selector:
    matchLabels:
      app: playground
  template:
    metadata:
      labels:
        app: playground
    spec:
      containers:
        - name: playground
          image: wil42/playground:v1
          ports:
            - containerPort: 8888


apiVersion: v1
kind: Service
metadata:
  name: mmakagon-playground
  namespace: dev
spec:
  type: ClusterIP
  selector:
    app: playground
  ports:
    - port: 8888
      targetPort: 8888



apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: mmakagon-ingress
  namespace: dev
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: mmakagon-playground
            port:
              number: 8888


В вашем первом скрипте (где создается кластер K3d) найдите строчку:

bash
    -p "8888:8888@loadbalancer"
Замените её на:

bash
    -p "8888:80@loadbalancer"
Почему это нужно: Встроенный балансировщик K3d (Traefik) слушает порт 80. Эта строчка перенаправит запросы с вашего компьютера (порт 8888) на порт 80 кластера, где их поймает Ingress и отправит в приложение.
