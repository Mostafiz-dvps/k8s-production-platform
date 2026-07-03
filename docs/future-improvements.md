# Future Improvements

## 1. GitOps with ArgoCD
- **What improvement is recommended:** Replace the current GitHub Actions `Mock deploy` step with ArgoCD-driven GitOps deployments from the Kubernetes manifest repository path.
- **Why it is needed:** The pipeline currently builds and pushes images, then only echoes what would be deployed; there is no real declarative cluster sync step.
- **How it helps the team or business:** Deployments become repeatable, auditable, and easier to roll back because Git becomes the source of truth for cluster state.
- **How it would be implemented:** Install ArgoCD on AKS, create ArgoCD Applications pointing to the environment-specific manifest/Helm paths, and have CI update image tags or chart values instead of running `kubectl apply` directly.
- **What risk it reduces:** Reduces manual deployment drift, inconsistent cluster state, and failed handoff between image build and runtime deployment.

## 2. CI/CD Environment Separation with Production Approval Gates
- **What improvement is recommended:** Split CI/CD into reusable/callable GitHub Actions workflows with branch-based environment targeting, such as `develop -> dev` and `main -> production` with required manual approval.
- **Why it is needed:** The current workflow is a single main-branch pipeline, which is too linear for safe multi-environment promotion.
- **How it helps the team or business:** Teams can test changes in dev/staging before production while keeping production releases controlled and visible.
- **How it would be implemented:** Create a reusable workflow for build/test/scan/deploy, configure GitHub Environments (`dev`, `staging`, `production`), map branches to environments, and require reviewers for the production environment.
- **What risk it reduces:** Reduces accidental production deployments, environment mix-ups, and unreviewed releases reaching customers.

## 3. Image Vulnerability Scanning
- **What improvement is recommended:** Add Trivy scanning to the GitHub Actions pipeline before pushing Docker images to GHCR.
- **Why it is needed:** Images can contain vulnerable OS packages or application dependencies even when tests pass.
- **How it helps the team or business:** Security issues are caught earlier in CI, before images become deployable artifacts.
- **How it would be implemented:** Run Trivy against the built backend and frontend images, fail the pipeline on configured severity thresholds, and optionally upload SARIF results to GitHub Security.
- **What risk it reduces:** Reduces the risk of shipping known CVEs, vulnerable base images, and unpatched dependencies into AKS.

## 4. Helm Chart
- **What improvement is recommended:** Convert the current raw `k8s/` manifests into a parameterized Helm chart.
- **Why it is needed:** Static YAML becomes harder to maintain as dev/staging/production need different image tags, hostnames, resource sizes, secrets, and replica counts.
- **How it helps the team or business:** One chart can serve multiple environments with consistent structure and smaller, safer environment-specific values files.
- **How it would be implemented:** Create `charts/platform/`, move Deployments/Services/Ingress/ConfigMap templates into Helm templates, and define `values-dev.yaml`, `values-staging.yaml`, and `values-production.yaml`.
- **What risk it reduces:** Reduces copy-paste manifest drift, inconsistent environment configuration, and mistakes during image/tag substitutions.

## 5. Kubernetes Autoscaling
- **What improvement is recommended:** Add Horizontal Pod Autoscalers for frontend and backend, plus Cluster Autoscaler for the AKS node pool.
- **Why it is needed:** Fixed replica and node counts do not react to real traffic spikes or quiet periods.
- **How it helps the team or business:** The platform can scale up for load and scale down to reduce cost without constant manual intervention.
- **How it would be implemented:** Install/enable metrics-server, create HPA objects based on CPU/memory for both workloads, and enable AKS Cluster Autoscaler settings on the node pool in Terraform.
- **What risk it reduces:** Reduces overload during traffic spikes, wasted compute during low traffic, and manual scaling errors.

## 6. Backup and Disaster Recovery
- **What improvement is recommended:** Add Velero for cluster and persistent volume backups, plus a documented RTO/RPO strategy.
- **Why it is needed:** AKS resources, persistent volumes, and production recovery steps need a tested restore path before an outage happens.
- **How it helps the team or business:** The team can recover from accidental deletes, cluster failures, or bad deployments with known recovery targets.
- **How it would be implemented:** Install Velero with Azure Blob Storage as the backup target, schedule namespace/PV backups, test restores in a non-production cluster, and document RTO/RPO per environment.
- **What risk it reduces:** Reduces data loss, long recovery windows, and uncertainty during production incidents.
