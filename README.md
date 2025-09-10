
# Fabric Capacity Approval Kit (Terraform + GitHub Actions/ Azure Logic Apps)

This repo enforces **central approval** for Microsoft Fabric capacity creation by combining:
- Azure Policy **deny** on `Microsoft.Fabric/capacities`
- GitHub Actions **Environment approvals**
- Time‑bound **policy exemption** (created by pipeline), then **Terraform** deployment

## Quick Start
1. Assign the deny policy in `policy/policy-deny-fabric-capacity.json` (or use built‑in Not allowed resource types).
2. Configure GitHub OIDC to Azure; add `AZURE_CLIENT_ID`, `AZURE_TENANT_ID` secrets.
3. Grant the SP **Contributor** + **Resource Policy Contributor** on the target RG.
4. Create Environment `fabric-prod` with required reviewers.
5. Run the workflow and approve.

See `docs/runbook-onepage.md` for a 1‑page guide.
