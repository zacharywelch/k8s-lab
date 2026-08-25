# k8s-lab

Kind cluster with Postgres on a data node, tiny app on app nodes, Ingress on localhost, and a NetworkPolicy.

## Prerequisites

- Docker
- kind
- kubectl

## Setup

### 1. Cluster

`kind-config.yaml` sets control-plane `ingress-ready=true`, host ports 80/443, and worker labels `workload=app` / `workload=data`.

```bash
kind create cluster --config kind-config.yaml
kubectl get nodes -L workload,ingress-ready
```

### 2. Postgres

```bash
kubectl apply -f postgres.yaml
kubectl get pods -o wide
```

### 3. App image

```bash
cd tiny-app
docker build -t tiny-app:dev .
kind load docker-image tiny-app:dev
cd ..
```

### 4. App

```bash
kubectl apply -f tiny-app.yaml
kubectl get pods -o wide
```

### 5. Check DB from app

```bash
APP=$(kubectl get pod -l app=tiny-app -o jsonpath='{.items[0].metadata.name}')
kubectl exec "$APP" -- ruby -e 'require "net/http"; puts Net::HTTP.get(URI("http://127.0.0.1:3000/db"))'
```

### 6. Ingress controller (Kustomize)

Pins the controller to the control-plane (`ingress-ready` + toleration for the control-plane taint):

```bash
kubectl apply -k ingress-nginx/
kubectl -n ingress-nginx get pods -o wide
```

Expect controller on `kind-control-plane`, `READY 1/1`.

### 7. Ingress + NetworkPolicy

```bash
kubectl apply -f tiny-app-ingress.yaml
kubectl apply -f postgres-netpol.yaml
kubectl get ingress,netpol
```

### 8. Test from laptop

```bash
curl http://localhost/health
curl http://localhost/db
```

### 9. Drain (optional)

```bash
kubectl drain kind-worker --ignore-daemonsets --delete-emptydir-data
kubectl get pods -o wide -l app=tiny-app
kubectl uncordon kind-worker
```

## Wipe

```bash
kind delete cluster
```
