1. **Pod is in CrashLoopBackOff. What do you check?**
- kubectl logs <pod> --previous to see the last crash reason and stack trace; check container args, env, and mounted secrets.  
- kubectl describe pod to inspect events (OOMKilled, CrashLoopBackOff details, image pull errors).  
- If config/secret related, verify Kubernetes Secret values (see k8s/backend-secret-example.yaml) and that the container command/entrypoint is correct.

2. **Deployment is successful, but app is not reachable. What do you check?**
- Confirm pod readiness: kubectl get pods and kubectl describe pod to ensure readiness probes passed.  
- Check Service and Endpoint objects (kubectl get svc && kubectl get endpoints) to ensure traffic routes to pod IPs, and verify Ingress rules / ingress-nginx logs for upstream errors.  

3. **Difference between readiness and liveness probe?**
- Liveness probe detects if a container is dead and should be restarted; readiness probe controls whether the pod receives traffic.  
- Use readiness for transient startup checks (DB migrations not yet done) and liveness for unrecoverable states; misconfigured probes often cause traffic loss or restart loops.

4. **Docker build works locally but fails in pipeline. Why?**
- Pipeline environments (GitHub Actions runners) often have different build context, missing build secrets, or network access to private registries/APTs; check for files excluded by .dockerignore.  
- Also confirm build args and secrets are supplied via Actions (secrets or TF_VAR_*) and that base images are accessible from the runner.

5. **Pipeline fails during Docker build. What do you check?**
- Inspect the workflow logs on GitHub Actions for the exact failing step, then re-run with debug enabled if needed.  
- Verify Dockerfile paths, .dockerignore, build cache, network/timeouts, and that required GitHub secrets (registry credentials, private repo tokens) are present and scoped to the job.

6. **Certificate renewal failed. What do you check?**
- Check cert-manager logs (kubectl -n cert-manager logs) and describe the Certificate/Challenge resources to see ACME errors or DNS validation failures.  
- Confirm the Ingress has the proper annotations for cert-manager, DNS records point to the ingress IP, and that the ACME challenge can reach the ACME server (or HTTP-01 path is routed through ingress-nginx).

7. **Ingress returns 502 or 504. What do you check?**
- 502: check ingress-nginx controller logs for backend connection errors and confirm Service endpoints exist; 504: look for backend timeouts and long-running requests.  
- Verify backend readiness, health endpoints, NGINX upstream timeouts, and whether the Service type/port matches the pod container port.

8. **Vendor SFTP connection to port 22 times out. What do you check?**
- Confirm network path: NSG on the egress and target side, firewall rules, and that the VM or SFTP service is listening on 22.  
- From a bastion or pod with appropriate egress, test tcp/ssh (nc/telnet) and check Azure NSG flow logs and effective security rules on the NIC/subnet.

9. **Terraform plan wants to recreate the cluster. What do you check?**
- Inspect the plan to see which attribute changed; common triggers are subnet IDs, node_resource_group_name, or changing identity/type.  
- If the change is unintended, compare state (terraform state show) vs code, and consider using terraform state mv or avoiding immutable changes; always save plan with -out before apply.

10. **How would you upgrade AKS/EKS safely?**
- Test the target Kubernetes version in dev/staging first, check available upgrades with az aks get-upgrades, and stagger upgrades by node pool.  
- Use surge upgrades / maxUnavailable controls, monitor node and pod readiness, and have rollback/runbook and backups ready before production upgrades.

11. **Frontend loads, but backend API calls fail. What do you check?**
- Inspect browser devtools network tab for CORS errors, endpoints, and response status.  
- Check Ingress and ingress-nginx logs for upstream errors, validate Service endpoints, and confirm backend pod logs and network policies are not blocking egress to the DB or other services.

12. **Backend pod is running, but database connection times out. What do you check?**
- Check the pod's DNS resolution and routing: kubectl exec into the pod and ping/psql the DB private IP/hostname.  
- Verify Azure NSG rules on the DB subnet allow traffic from the AKS subnet, Private DNS resolves to private IP (privatelink.postgres.database.azure.com), and that credentials are valid in the Secret.

13. **Private DNS is not resolving database hostname. What do you check?**
- Ensure the Private DNS Zone (e.g. privatelink.postgres.database.azure.com) is linked to the VNet where AKS runs and that the Private Endpoint created the expected A record.  
- From a pod, run nslookup/dig for the hostname and inspect Azure portal Private Endpoint and DNS zone records if resolution fails.

14. **How would you rotate database credentials safely?**
- Create the rotated credentials in the DB, update the secret in Azure Key Vault or Kubernetes (via External Secrets / Key Vault CSI), and perform a controlled rollout of backend pods to pick up new creds.  
- Use rolling pod restarts (kubectl rollout restart deployment/backend) and monitor errors; keep the old credentials active until all pods successfully connect.

15. **Secrets were accidentally committed to GitHub. What do you do?**
- Immediately revoke/rotate the exposed secrets (DB passwords, Azure client secrets, tokens) and remove the secret from Git history using git filter-repo or BFG, then force-push the cleaned branch.  
- Treat the leak as an incident: rotate affected credentials, review audit logs, and update policy to prevent future commits (pre-commit hooks, repo scanning, and secret scanning in GitHub).
