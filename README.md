# AI Stock Pulse — GitOps manifests

Desired state for the EKS cluster. Argo CD watches this repository and syncs
what is in `apps/`. Terraform does **not** apply the application or the
monitoring stack; it only installs Argo CD, which then pulls from here.

Infrastructure (VPC, EKS, RDS, ALB controller, External Secrets) is in
[ai-stock-pulse-infra](https://github.com/OmriHalpert/ai-stock-pulse-infra).
Application source is
[ai-stock-pulse-services](https://github.com/OmriHalpert/ai-stock-pulse-services).

![Argo CD](https://img.shields.io/badge/Argo_CD-GitOps-EF7B4D?logo=argo&logoColor=white)
![Helm](https://img.shields.io/badge/Helm-3-0F1689?logo=helm&logoColor=white)
![Prometheus](https://img.shields.io/badge/Prometheus-Operator-E6522C?logo=prometheus&logoColor=white)
![Grafana](https://img.shields.io/badge/Grafana-dashboards-F46800?logo=grafana&logoColor=white)

## How deploy works

```
GitHub Actions (services repo)
  → build/push images to ECR
  → commit new tags in charts/ai-stock-pulse/values-dev.yaml
Argo CD (in-cluster)
  → pull this repo
  → helm template the app into namespace `dev`
  → sync kube-prometheus-stack, Loki, Alloy into `monitoring`
```

CI never talks to the Kubernetes API. Changing what runs in the cluster is a
git commit on `main`.

## Layout

```
apps/                         # Argo CD Application CRs (app-of-apps children)
  argocd-dev-app.yaml         # the Nest/React/Python Helm release
  kube-prometheus-stack.yaml
  loki.yaml
  alloy.yaml
  alertmanager-telegram.yaml
charts/ai-stock-pulse/        # application Helm chart
monitoring/                   # Helm values for the monitoring charts
```

`root-app.yaml` is the parent Application Terraform installs: it points Argo at
`apps/` so every file in that folder becomes a child app.

## Secrets

Nothing in this repo is a live token. The chart's `values-secrets.yaml` is
gitignored; the committed file is `values-secrets.yaml.example` with empty
strings.

On AWS, External Secrets Operator reads AWS Secrets Manager and materializes
Kubernetes Secrets. Helm only names those secrets (`secrets.existingSecret`).
Telegram, LLM, Finnhub, and the RDS URL never pass through git.

## Chart

See [charts/ai-stock-pulse/README.md](charts/ai-stock-pulse/README.md) for local
Helm install, probes, and values.
