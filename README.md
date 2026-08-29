# k8s-lab

Kind lab with three self-contained setups: a single-cluster stack, then two
kind clusters, or [cells](https://docs.aws.amazon.com/wellarchitected/latest/reducing-scope-of-impact-with-cell-based-architecture/what-is-a-cell-based-architecture.html), wired the same way with Kustomize, then again
with Helm, plus a thin router to demo tenant-based cell routing and blast
radius.

## Prerequisites

- Docker
- [kind](https://kind.sigs.k8s.io/)
- kubectl
- Helm (only needed for `cells-helm/`)

## Sections

- [single-stack](single-stack)
- [cells-kustomize](cells-kustomize)
- [cells-helm](cells-helm)

## Reset everything

```bash
for c in $(kind get clusters 2>/dev/null); do kind delete cluster --name "$c"; done
```
