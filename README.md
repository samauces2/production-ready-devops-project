<h1 align="center">One-Click DevOps Platform Deployment</h1>

<p align="center">
  Full DevSecOps pipeline with GitHub Actions, Kubernetes (AKS), ArgoCD, Prometheus & Grafana
</p>

<p align="center">
  <b> Designed for recruiters: Run everything with ONE CLICK</b>
</p>

##  One-Click Deployment

Follow these steps:

1. Click the button below 'run pipeline'
2. Go to "Run workflow"
3. Click "Run workflow" again
4. Wait ~10-15 minutes
5. Access the job "deploy"
6. Inspect the step "Install Tools and Deploy" the last line will contain info needed to see demo
7. Access the elements with the info given

### resources will be deleted in 10 minutes after deployment, I don't want to maintain (pay $$$) anything :D

<p align="center">
  <a href="https://github.com/samauces2/DevSecOps-Demo/actions/workflows/ci_cd.yml">
    <img src="https://img.shields.io/badge/ Run%20Pipeline-GitHub%20Actions-blue?style=for-the-badge">
  </a>
</p>


## What this project demonstrates

This is NOT just a frontend demo.

It showcases a real-world DevOps workflow:

- ✅ Infrastructure as Code (Terraform)
- ✅ Containerization (Docker)
- ✅ CI/CD (GitHub Actions)
- ✅ Kubernetes deployment (AKS)
- ✅ GitOps (ArgoCD)
- ✅ Monitoring (Prometheus + Grafana)
- ✅ Secure & automated provisioning

## Architecture

1. GitHub Actions triggers pipeline
2. Docker builds application image
3. Terraform provisions AKS
4. Kubernetes deploys workloads
5. ArgoCD manages GitOps sync
6. Prometheus collects metrics
7. Grafana visualizes data


## Workflows

This repository contains multiple pipelines:

|    Workflow     |            Purpose        |
|-----------------|---------------------------|
| Image (ci.yml)  | Build & push Docker image |
| Infra (cd.yml)  | Deploy AKS with Terraform |
| Full(ci_cd.yml) |   End-to-end deployment   |

## Observability

- Prometheus metrics collection
- Grafana dashboards

## Why this project matters

This project simulates a real production-ready DevOps workflow:

- Automated infrastructure provisioning
- GitOps-based deployments
- Scalable Kubernetes architecture
- End-to-end observability

Built to demonstrate real DevOps engineering skills — not just theory.

##  Application Preview
<div align="center">
  <img src="./app/public/assets/DevSecOps.png" alt="Logo" width="100%" height="100%">

  <br>
    <img src="./app/public/assets/netflix-logo.png" alt="Logo" width="100" height="32">
</div>

<br />

<div align="center">
  <img src="./app/public/assets/home-page.png" alt="Logo" width="100%" height="100%">
  <p align="center">Home Page</p>
</div>


