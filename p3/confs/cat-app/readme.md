```
cd cat-app
```

```
docker login
```

```
docker build --build-arg APP_VERSION=v1 -t onnamcadva/cat-app:v1 .
```

```
docker push onnamcadva/cat-app:v1
```

```
docker build --build-arg APP_VERSION=v2 -t onnamcadva/cat-app:v2 .
```

```
docker push onnamcadva/cat-app:v2
```

```
docker run -p 8888:8888 onnamcadva/cat-app:v1
```

```
curl http://localhost:8888/
```
