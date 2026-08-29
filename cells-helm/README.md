# cells-helm

Two kind clusters or [cells](https://docs.aws.amazon.com/wellarchitected/latest/reducing-scope-of-impact-with-cell-based-architecture/what-is-a-cell-based-architecture.html) each wired the same way as `single-stack/`
but applied with the `tiny-stack` Helm chart and per-cell values files.

## Layout

```text
kind-cell-a.yaml     # kind cluster definition for cell-a (host port 8081)
kind-cell-b.yaml     # kind cluster definition for cell-b (host port 8082)
tiny-stack/          # Helm chart: postgres + demo app + ingress + netpol
demo/                # image source (Ruby/Sinatra app)
ingress-nginx/       # ingress controller kustomization
router.rb / router.conf # tenant-based router in front of both cells
```

## Prerequisites

Docker, kind, kubectl, Helm. nginx optional (`router.conf`).

## Cluster setup

```bash
kind create cluster --config kind-cell-a.yaml
kind create cluster --config kind-cell-b.yaml

cd demo
docker build -t demo:dev .
kind load docker-image demo:dev --name cell-a
kind load docker-image demo:dev --name cell-b
cd ..

kubectl apply -k ingress-nginx/ --context kind-cell-a
kubectl apply -k ingress-nginx/ --context kind-cell-b
```

## Apply

```bash
helm upgrade --install tiny-stack ./tiny-stack \
  -f tiny-stack/values-cell-a.yaml --kube-context kind-cell-a

helm upgrade --install tiny-stack ./tiny-stack \
  -f tiny-stack/values-cell-b.yaml --kube-context kind-cell-b
```

## Test cells

```bash
curl http://localhost:8081/db
curl http://localhost:8082/db
```

## Router (tenant 0,1 -> A; 2,3 -> B)

```bash
ruby router.rb
# or: nginx -c $PWD/router.conf -g "daemon off;"

curl -H "X-Tenant-Id: 0" http://127.0.0.1:8090/db
curl -H "X-Tenant-Id: 2" http://127.0.0.1:8090/db
```

## Blast radius

```bash
docker stop cell-b-control-plane
curl -H "X-Tenant-Id: 0" http://127.0.0.1:8090/health   # still ok
curl -H "X-Tenant-Id: 2" http://127.0.0.1:8090/health   # fails
docker start cell-b-control-plane
```

## Stop / wipe

```bash
docker ps -q --filter "label=io.x-k8s.kind.cluster" | xargs docker stop
kind delete cluster --name cell-a
kind delete cluster --name cell-b
```
