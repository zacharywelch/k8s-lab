# single-stack

One kind cluster, plain manifests — Postgres on a data node, the
`demo` app on app nodes, Ingress on localhost, and a NetworkPolicy.

## Layout

```text
kind-config.yaml    # kind cluster definition (control-plane + app/data workers)
postgres.yaml       # Postgres Secret, PVC, Deployment, Service
demo.yaml           # demo app Secret, Deployment, Service
demo-ingress.yaml   # Ingress routing / -> demo app
postgres-netpol.yaml # NetworkPolicy: only the demo app can reach postgres
demo/               # image source (Ruby/Sinatra app)
ingress-nginx/      # ingress controller kustomization
```

## Prerequisites

Docker, kind, kubectl.

## Setup

```bash
kind create cluster --config kind-config.yaml
kubectl get nodes -L workload,ingress-ready

kubectl apply -f postgres.yaml

cd demo
docker build -t demo:dev .
kind load docker-image demo:dev
cd ..

kubectl apply -f demo.yaml
kubectl apply -k ingress-nginx/
kubectl apply -f demo-ingress.yaml
kubectl apply -f postgres-netpol.yaml

curl http://localhost/health
curl http://localhost/db
```

Ingress controller should land on `kind-control-plane`.

## Drain check (optional)

```bash
kubectl drain kind-worker --ignore-daemonsets --delete-emptydir-data
kubectl get pods -o wide -l app=demo
kubectl uncordon kind-worker
```

## Wipe

```bash
kind delete cluster
```
