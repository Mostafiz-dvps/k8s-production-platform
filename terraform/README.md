# Terraform AKS Infrastructure

## 1. Overview
This Terraform configuration provisions the Azure foundation for running the platform on AKS using only local custom modules.

It currently creates:
- an Azure **Resource Group** for the environment/cluster
- a **Virtual Network** with:
  - an **AKS subnet** (`10.0.1.0/24`)
  - a **reserved private endpoint subnet** for a future database (`10.0.2.0/24`)
- an **AKS cluster** with a system-assigned managed identity
- an **Azure Container Registry (ACR)** for container images
- a **Log Analytics workspace** plus **AKS diagnostic settings** for logs/metrics

Module structure:
- `main.tf` — root composition layer
- `provider.tf` — Azure provider and remote backend
- `variables.tf` — root input variables
- `outputs.tf` — root outputs
- `modules/network` — VNet and subnet resources
- `modules/aks` — AKS cluster resource
- `modules/acr` — Azure Container Registry
- `modules/monitoring` — Log Analytics and AKS diagnostics

---

## 2. How to Use
Initialize Terraform:

```bash
terraform init
```

Plan a specific environment using a var-file:

```bash
terraform plan -var-file=dev.tfvars
terraform plan -var-file=staging.tfvars
terraform plan -var-file=production.tfvars
```

Apply a specific environment:

```bash
terraform apply -var-file=dev.tfvars
terraform apply -var-file=staging.tfvars
terraform apply -var-file=production.tfvars
```

A typical `dev.tfvars` would include values such as:

```hcl
environment         = "dev"
location            = "eastus"
cluster_name        = "platform-dev"
node_size           = "Standard_D2s_v3"
node_count          = 2
kubernetes_version  = "1.29"
```

Practical notes:
- keep one `.tfvars` file per environment
- do not commit secrets into `.tfvars`
- prefer reviewing `terraform plan` output before every apply

---

## 3. How to Safely Upgrade AKS
The intended upgrade path is to change `kubernetes_version` and let Terraform apply the AKS version change.

Recommended workflow:
1. Check what versions Azure currently supports:

```bash
az aks get-upgrades \
  --resource-group <rg-name> \
  --name <cluster-name>
```

2. Upgrade in **dev** first, then **staging**, then **production**.
3. Change `kubernetes_version` in the environment's `.tfvars` file.
4. Run:

```bash
terraform plan -var-file=<env>.tfvars -out=<env>.plan
terraform apply <env>.plan
```

Operational guidance:
- verify addon and workload compatibility before upgrading production
- upgrade node pools in a controlled way, one pool at a time when you add more pools later
- use **surge upgrades** on node pools to keep spare capacity during rolling replacement and avoid downtime
- confirm cluster health, node readiness, and application readiness after each upgrade step

---

## 4. How to Add or Resize Node Pools
There are two common paths:

### Resize the default node pool
- change `node_count` to scale capacity up or down
- change `node_size` to move the default pool to a different VM SKU

Terraform behavior depends on the field being changed:
- `node_count` is usually an **in-place** update
- some AKS node pool fields can trigger **replacement** rather than in-place change
- VM size changes may be disruptive depending on Azure/AKS behavior for that field at the time of apply

### Add additional node pools
For production-style clusters, it is usually better to add explicit additional node pools with separate resources such as:
- `azurerm_kubernetes_cluster_node_pool`

That approach is preferred when you want:
- separate system vs application pools
- different VM sizes for different workloads
- isolated upgrades or scaling behavior
- lower-risk rolling changes one pool at a time

Practical rule:
- use the default pool for the baseline system capacity
- add separate node pool resources for specialized workloads instead of overloading the default pool

---

## 5. How to Maintain Terraform State
This configuration uses the remote **`azurerm` backend** defined in `provider.tf`.

That means Terraform state should live in a pre-existing Azure Storage Account, not on a developer laptop.

Important practices:
- use the remote backend for shared state
- rely on Azure Storage **lease-based state locking** to prevent concurrent conflicting applies
- never manually edit the state file blob
- do not delete or rename state files casually
- use `terraform state` commands only for exceptional repair or migration work

Examples of exceptional state operations:

```bash
terraform state list
terraform state show <address>
terraform state mv <from> <to>
terraform state rm <address>
```

Only use those commands when you clearly understand the effect on real infrastructure.

---

## 6. How to Avoid Downtime During Cluster Changes
When changing AKS infrastructure, assume some changes are operationally sensitive.

Use these safeguards:
- prefer **rolling** changes over destructive changes
- use **node pool surge settings** during upgrades so replacement nodes come up before older ones drain
- define **PodDisruptionBudgets** at the Kubernetes application layer so voluntary disruptions do not evict too many pods at once
- ensure workloads have multiple replicas before maintenance
- review any Terraform plan that shows replacement of the AKS cluster or node pools
- avoid changing immutable AKS fields that force recreation unless downtime is planned

Cluster changes should be tested in dev/staging first, especially version upgrades, subnet changes, and identity/networking changes.

---

## 7. How to Separate Dev / Staging / Production
Keep environments isolated both in variables and in state.

Recommended approach:
- `dev.tfvars`
- `staging.tfvars`
- `production.tfvars`

Each environment should also use a distinct backend state key, for example:
- `dev.terraform.tfstate`
- `staging.terraform.tfstate`
- `production.terraform.tfstate`

In practice, that usually means either:
- separate backend configs / backend keys per environment, or
- separate Terraform workspaces

Practical preference for infrastructure like AKS:
- separate backend keys per environment is often simpler and more explicit than relying heavily on workspaces

Whatever model you use, do not let dev/staging/production share the same state file.

---

## 8. How Secrets Are Handled Outside Terraform Code
Do not store secrets directly in Terraform code or committed `.tfvars` files.

Rules to follow:
- no secrets in committed `.tfvars`
- future secret input variables should be marked with `sensitive = true`
- inject real secrets through CI/CD environment variables when running Terraform
- or fetch them from **Azure Key Vault** at apply time

Examples of acceptable patterns:
- pipeline sets `TF_VAR_<name>` environment variables at runtime
- Terraform reads secret values from Azure Key Vault data sources
- CI/CD pulls environment-specific credentials from a secure secret store

Reference:
- `../docs/secrets-management.md`

That document should remain the source of truth for project-wide secret handling rules.

---

## 9. What to Check if Terraform Plan Wants to Recreate the Cluster
If `terraform plan` shows that AKS will be destroyed and recreated, stop and review the diff carefully before applying.

Common causes include changes such as:
- changing the subnet attached to the cluster/node pool
- changing `node_resource_group_name`
- changing certain immutable AKS fields
- refactoring modules in a way that changes resource addresses without state migration

Practical review process:
1. Save the plan first:

```bash
terraform plan -var-file=<env>.tfvars -out=<env>.plan
```

2. Review the proposed replacement in detail.
3. Confirm whether the replacement is expected, safe, and scheduled.
4. If the change is not intentional, fix the configuration before applying.

Important reminder:
- a forced AKS cluster recreation can cause **real downtime**
- any plan that destroys and recreates the cluster should be treated as a deliberate maintenance event, not a routine apply

When in doubt, pause and inspect the exact field change instead of applying immediately.
