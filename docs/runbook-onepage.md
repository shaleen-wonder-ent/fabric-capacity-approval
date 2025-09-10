
# One-Page Runbook — Fabric Capacity with Policy Guardrails & GitHub Approvals

**Goal:** Prevent ad-hoc `Microsoft.Fabric/capacities` creation, allow only via an approved CI/CD run.

## 1) Set Governance (Deny Policy)
- Assign a deny policy for resource type `Microsoft.Fabric/capacities` at **Management Group** or **Subscription** scope.
- Use the custom JSON in `policy/policy-deny-fabric-capacity.json` or the built‑in **Not allowed resource types**.

## 2) Prepare Access (OIDC + RBAC)
- Create an Entra **app registration** (service principal) and configure **GitHub OIDC federated credential**.
- Grant the SP these roles at the **target Resource Group**:
  - **Contributor** (to deploy the capacity)
  - **Resource Policy Contributor** (to create/delete policy exemptions)

## 3) Wire GitHub Approvals
- In the repo: Settings → **Environments** → `fabric-prod` → add **Required reviewers**.
- Add repo secrets: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`.

## 4) Deploy via Terraform (Workflow)
- File: `.github/workflows/deploy-fabric-capacity-terraform.yml`
- Flow:
  1. Login to Azure with OIDC
  2. **Create time‑bound policy exemption** at the RG scope
  3. `terraform apply` → creates `Microsoft.Fabric/capacities`
  4. **Remove exemption** (always)

## 5) Run
- Actions → run the workflow → fill inputs → approve the environment gate.
- Validate in Azure Activity Log (exemption + capacity create) and Terraform outputs.

## Troubleshooting
- **Deny persists** → Ensure exemption **scope** is the same RG you deploy into and `policyAssignmentId` is correct.
- **RBAC error** → Confirm **Resource Policy Contributor** on RG for SP.
- **Name/region errors** → Confirm capacity name regex and region supported for Fabric.

## Additional read
- **https://learn.microsoft.com/en-us/fabric/enterprise/capacity-planning-manage-capacity-growth-governance**
- **https://learn.microsoft.com/en-us/fabric/enterprise/capacity-planning-overview**
