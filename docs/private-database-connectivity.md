# Private Database Connectivity

## Production Architecture Choice
- Use **Azure Database for PostgreSQL Flexible Server** in a **private-only** production setup.
- Practical Azure pattern:
  - deploy the **AKS cluster into a VNet/subnet**
  - deploy PostgreSQL Flexible Server with **private access via VNet integration** or expose it through a **Private Endpoint**
  - place both in the **same VNet** or in **peered VNets**
- Result: backend-to-database traffic stays on Azure private networking and does **not** traverse the public internet.

## How AKS Connects Privately
- The backend runs in AKS on nodes attached to a private subnet inside the VNet.
- The PostgreSQL server is reachable only through its **private IP**:
  - either because the Flexible Server is deployed privately into the VNet
  - or because a **Private Endpoint** is created for the server inside the VNet
- The backend connects using the normal PostgreSQL hostname, but DNS resolves that hostname to the database's **private address**.
- From an operations perspective, this should feel like the backend is talking to an internal service, not an internet-facing database.

## Private DNS Is Required
- Azure private database connectivity is not complete until **Private DNS** is wired correctly.
- Create and link a **Private DNS Zone** such as:
  - `privatelink.postgres.database.azure.com`
- Link that zone to the AKS/database VNet so the PostgreSQL server name resolves to the **private IP**, not a public IP.
- If DNS is wrong, the app may try to connect to the public endpoint even if private networking exists on paper.
- Hands-on check:
  - from a pod or node in AKS, resolve the DB hostname and confirm it returns a **10.x/172.16-31.x/192.168.x** address or the expected private Azure address range for the subnet

## NSG Rules on the Database Side
- Put the database subnet or private endpoint subnet behind a **Network Security Group (NSG)**.
- Allow **inbound** traffic only from the **AKS node subnet** or the dedicated **pod subnet** if using Azure CNI on:
  - TCP `5432` for PostgreSQL
- Deny all other inbound sources.
- Keep the rule narrow:
  - source = AKS subnet CIDR
  - destination = DB subnet/private endpoint
  - port = `5432`
- This gives a second enforcement layer even if someone misconfigures application routing later.

## How Only the Backend Can Reach the Database
- Restrict access at **two layers**:

### In Kubernetes
- Apply a **NetworkPolicy** so only the **backend pods** can send egress traffic to the database destination on port `5432`.
- Do **not** allow broad namespace-wide egress if only the backend needs database access.
- Frontend pods should have no egress rule allowing database connectivity.

### In Azure Networking
- The database-side **NSG** should allow traffic only from the AKS subnet used by workloads that host the backend.
- Combined effect:
  - backend pods have an allowed egress path
  - frontend pods do not have an allowed Kubernetes path
  - anything outside the AKS subnet is blocked by the NSG
- In practice, frontend pods have **no network path** to the database.

## Database Credentials
- Store database connection settings and credentials as Kubernetes secrets for runtime injection, following:
  - `k8s/backend-secret-example.yaml`
  - `docs/secrets-management.md`
- For production, treat **Azure Key Vault** as the source of truth.
- Recommended production flow:
  - secrets live in Azure Key Vault
  - AKS syncs or mounts them through a supported integration
  - backend pods receive them as environment variables or mounted secret material
- Do not commit real DB credentials into manifests, images, `.env` files, or CI logs.

## How to Confirm the Database Is Not Publicly Accessible
- In Azure, verify the PostgreSQL server shows:
  - **Public network access = Disabled**
- Test connectivity from a machine **outside the VNet**:
  - connection should fail or time out
  - DNS should not lead to a reachable public database endpoint
- Test connectivity from the backend inside AKS:
  - connection should succeed over the private address
- Review **NSG flow logs** to confirm traffic is only coming from the AKS subnet and only on the expected database port.

## Practical Production Summary
- **AKS** runs inside a VNet.
- **PostgreSQL Flexible Server** is private-only through **VNet integration** or a **Private Endpoint**.
- **Private DNS Zone** makes the DB hostname resolve privately.
- **NSG rules** allow only AKS-originated traffic on `5432`.
- **NetworkPolicy** ensures only backend pods can egress to the database.
- **Azure Key Vault** holds the real credentials.
- Net result: the database is not internet-exposed, and only the backend has a valid private path to it.
