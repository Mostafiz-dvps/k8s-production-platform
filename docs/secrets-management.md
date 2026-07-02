# Secrets Management

## Purpose
- Define how sensitive values should be handled in this project's CI/CD pipeline and Kubernetes deployment.
- Keep credentials out of source control, container images, logs, and static manifests.

## Never Commit or Hardcode Secrets
- Secrets must never be committed to Git, even in examples, comments, or old commit history.
- Secrets must not be hardcoded in:
  - `Dockerfile`s
  - GitHub Actions workflow YAML
  - Kubernetes manifests checked into the repo
  - frontend JavaScript or static config files
- Hardcoded secrets are difficult to rotate, easy to leak, and become part of the permanent history of images and repositories.

## GitHub Actions Secrets in This Project
- This project's GitHub Actions workflow uses `GITHUB_TOKEN` to authenticate to `ghcr.io` and push Docker images.
- `GITHUB_TOKEN` is provided by GitHub Actions at runtime and should be referenced through workflow expressions such as:
  - `${{ secrets.GITHUB_TOKEN }}`
- Secrets should only be exposed to the specific job or step that needs them.

## Adding Additional CI/CD Secrets
- Additional secrets such as database credentials, cloud credentials, or registry tokens should be stored as GitHub repository or environment secrets.
- Typical examples:
  - `DB_USERNAME`
  - `DB_PASSWORD`
  - `AZURE_CLIENT_ID`
  - `AZURE_CLIENT_SECRET`
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
- In workflows, reference them through `secrets.*`, for example:
  - `${{ secrets.DB_PASSWORD }}`
- Prefer passing secrets through environment variables at runtime rather than embedding them directly in shell commands.
- Scope secrets to the smallest practical environment and avoid sharing one credential across all environments.

## Kubernetes Secrets for Runtime Configuration
- Kubernetes Secrets are used to provide runtime application configuration to containers without baking values into images.
- The backend deployment should reference a Kubernetes Secret manifest such as `backend-secret-example.yaml` (to be added separately) as the template for required keys.
- In practice, the application consumes those values through:
  - environment variables sourced from a Secret
  - mounted secret files when needed
- Static Kubernetes Secrets are acceptable for local or basic setups, but they should still be treated as sensitive because base64 encoding is not encryption.

## Production Secret Stores
- Production environments should use a managed secrets service instead of relying only on static Kubernetes Secrets.
- Recommended options:
  - Azure Key Vault
  - AWS Secrets Manager
- Why:
  - centralized secret storage
  - better auditability
  - native rotation support
  - tighter IAM/RBAC control
  - reduced risk of stale secrets sitting in cluster manifests

### Typical Integration Pattern
- The application or cluster does not store raw production secrets in Git.
- Kubernetes pulls secrets from the external manager at runtime using an integration such as:
  - Azure Key Vault CSI Driver
  - External Secrets Operator
- Those integrations map cloud-stored secrets into Kubernetes as mounted files or synced Kubernetes Secret objects.
- The app then reads them the same way it would read any other runtime secret.

## Best Practices
- Rotate secrets regularly and immediately after suspected exposure.
- Use least-privilege credentials for CI jobs, registries, databases, and cloud APIs.
- Never print secret values in logs, debug output, or error messages.
- Mask secrets in CI/CD systems and avoid commands that echo them back to the console.
- Keep `.env` files out of version control; this repo's `.gitignore` already excludes `.env` and `.env.*`.
- Separate credentials by environment so development, staging, and production do not share the same secret values.
- Remove unused secrets and review access periodically.
