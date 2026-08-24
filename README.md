# k8s-lab

Kind cluster with Postgres on a data node and a tiny app on app nodes.

## Prerequisites

- Docker
- kind
- kubectl

## Setup

### 1. Cluster

```bash
kind create cluster --config kind-config.yaml
```

### 2. Labels

```bash
kubectl get nodes -L workload
```

### 3. Postgres

```bash
kubectl apply -f postgres.yaml
kubectl get pods -o wide
```

### 4. App image

```bash
cd tiny-app
docker build -t tiny-app:dev .
kind load docker-image tiny-app:dev
cd ..
```

### 5. App

```bash
kubectl apply -f tiny-app.yaml
kubectl get pods -o wide
```

### 6. Check DB from app

```bash
APP=$(kubectl get pod -l app=tiny-app -o jsonpath='{.items[0].metadata.name}')
kubectl exec "$APP" -- ruby -e 'require "net/http"; puts Net::HTTP.get(URI("http://127.0.0.1:3000/db"))'
```

### 7. Drain (optional)

```bash
kubectl drain kind-worker --ignore-daemonsets --delete-emptydir-data
kubectl get pods -o wide -l app=tiny-app
kubectl uncordon kind-worker
```

## Stop / start

```bash
docker ps -q --filter "label=io.x-k8s.kind.cluster=kind" | xargs docker stop
docker ps -aq --filter "label=io.x-k8s.kind.cluster=kind" | xargs docker start
```

## Wipe

```bash
kind delete cluster
```
