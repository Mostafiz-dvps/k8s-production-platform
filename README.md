# Kubernetes Production Platform

A production-style Kubernetes platform demonstrating containerization, CI/CD, orchestration, infrastructure as code, and security best practices.

## Architecture Overview

The project contains a simple frontend and backend application:

- **Frontend**: static web UI served by nginx.
- **Backend**: Node.js API exposing `/` and `/health` endpoints on port `8080`.
- **Local Docker Compose**: the frontend container uses `BACKEND_URL=http://backend:8080` and communicates with the backend over the Compose service network.
- **Kubernetes**: frontend and backend run as separate Deployments and communicate through Kubernetes Service DNS, using the backend service name (`http://backend:8080`).

## Tech Stack

- Docker
- Docker Compose
- GitHub Actions
- GitHub Container Registry (GHCR)
- Kubernetes
- Terraform
- Azure AKS
- nginx-ingress

## Repository Structure

```text
.
├── frontend/             # nginx-served frontend application and Dockerfile
├── backend/              # Node.js backend API, tests, and Dockerfile
├── k8s/                  # Kubernetes manifests for Deployments, Services, Ingress, ConfigMap, and Secret example
├── terraform/            # Azure infrastructure as code for AKS, ACR, VNet, and monitoring
├── docs/                 # Operational docs, troubleshooting notes, security notes, and future improvements
└── .github/workflows/    # GitHub Actions CI/CD workflow definitions
```

## Running Locally

Start the stack with Docker Compose:

```bash
docker compose up -d
```

Test the backend:

```bash
curl http://localhost:8080/
curl http://localhost:8080/health
```

Open the frontend in a browser:

```text
http://localhost:3000
```

## CI/CD Pipeline

The workflow in `.github/workflows/deploy.yml` currently runs on pushes to `main`.

It performs three main stages:

1. **Test**: installs backend dependencies and runs the backend test suite.
2. **Build and push**: builds backend and frontend Docker images, tags them with `latest` and the short git SHA, and pushes them to GHCR.
3. **Mock deploy**: prints the image tags that would be deployed to Kubernetes; this is intentionally a placeholder for a future real deployment step.

## Kubernetes Deployment

Kubernetes manifests live in `k8s/`.

Conceptual deploy command:

```bash
kubectl apply -f k8s/
```

The manifests define frontend/backend Deployments, Services, Ingress, ConfigMap, and a backend Secret example. Image tags in the manifests are pinned to explicit versions instead of using `latest`, making deployments more reproducible and rollbacks safer.

## Infrastructure as Code

The `terraform/` directory provisions Azure infrastructure using custom local modules.

It covers:

- Azure Resource Group
- VNet and subnets
- AKS cluster
- Azure Container Registry
- Log Analytics monitoring and AKS diagnostic settings

See [`terraform/README.md`](terraform/README.md) for full usage and operations details.

## Documentation Links

- [Troubleshooting](docs/troubleshooting.md)
- [Future Improvements](docs/future-improvements.md)
- [Private Database Connectivity](docs/private-database-connectivity.md)
- [Secrets Management](docs/secrets-management.md)
- [Terraform README](terraform/README.md)

## Author

Md. Mostafiz Ul Islam — [GitHub](https://github.com/Mostafiz-dvps)
