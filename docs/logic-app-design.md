# Fabric Capacity Approval and Provisioning using Logic Apps

## Overview
This design replaces the Terraform-based approach with a Logic App workflow that handles the approval process and provisioning of Fabric Capacities in Azure.

## Architecture Components

# Full Logic App Design: Fabric Capacity Approval & Provisioning

This document provides a complete design for the Fabric Capacity Approval Logic App. It is based on the implementation in `infra/logic-apps/fabric-capacity-approval-workflow.json` and expands on the simplified design with action-level details, validation, retries, RBAC, testing and deployment guidance.

## Summary

Purpose: Provide an approval-driven flow to provision Microsoft Fabric capacity while enforcing policy governance. The Logic App uses a Teams approval card to request human approval, creates a short-lived policy exemption, provisions the capacity, then removes the exemption and notifies the requester.

Scope: Designed for manual-trigger flows initiated by an operator or automation with required input fields.

## High-level flow

1. Manual HTTP trigger receives request body
2. Validate input parameters (script-based validation)
3. If validation passes, send Teams approval card and wait for response
4. On approval:
     - Create temporary policy exemption (15-minute expiry)
     - Create Fabric capacity
     - Remove the temporary exemption
     - Send success email to requester
5. On rejection: send rejection email
6. If validation fails: send validation-failed email

## Trigger

- Type: HTTP Request trigger (manual)
- The request schema is enforced by a ParseJson action and an initial script validation (see `Parse_Request_Body` in the workflow).
- Expected payload:
    - `subscriptionId` (string)
    - `resourceGroup` (string)
    - `location` (string)
    - `capacityName` (string)
    - `skuName` (string)
    - `adminMembers` (string, comma-separated UPNs or SP objectIds)
    - `policyAssignmentId` (string)
    - `requesterEmail` (string)
    - `justification` (optional string)

## Actions (detailed)

### Parse_Request_Body
- Runs JavaScript-like validation code (stored in the action `code` field) to verify:
    - `capacityName` conforms to `^[a-z][a-z0-9]{2,62}$`
    - `skuName` belongs to a whitelist (F2, F4, F8, F16, F32)
    - `requesterEmail` is a valid email
    - `adminMembers` contains valid UPNs or GUIDs
- Returns an object `{ isValid: boolean, errors: [] }`

Notes: Consider moving validation logic to an Azure Function for clarity and maintainability if validation needs to be extended.

### Check_Validation_Result / Create_Teams_Approval
- If validation passes, the app posts a Teams approval card via `ApiConnectionWebhook` (Teams Connector). The card includes request details and an approval/reject option.
- The Teams card uses `listCallbackUrl()` to accept responses.

### Check_Approval
- If the approver selects `Approve`, the app proceeds to create a policy exemption and the capacity (see below).
- If `Reject`, the app sends a rejection email to the requester (Office365 connector).

### Create_Policy_Exemption
- Sends a PUT to the Azure Management API to create a `policyExemptions` resource scoped to the resource group.
- Exemption name: `temp-exempt-{runName}` (unique per run)
- `expiresOn` set to `addMinutes(utcNow(), 15)` (15-minute expiry)
- Authentication: `ManagedServiceIdentity`

### Create_Fabric_Capacity
- Sends PUT to the Fabric management endpoint to create a `Microsoft.Fabric/capacities/{capacityName}` resource.
- Uses body with `sku` and `properties.administration.members` built from `adminMembers` string.
- Depends on `Create_Policy_Exemption` succeeding.

### Remove_Policy_Exemption
- Sends DELETE to the exemption resource to proactively remove it after successful provisioning.
- Also relies on `expiresOn` as a safety net.

### Send_Success_Email / Send_Rejection_Email / Send_Validation_Error_Email
- Uses Office365 connector to notify the requester of the outcome.

## Error handling & retries

- Current workflow has basic `runAfter` dependencies but minimal retry policy.
- Recommended improvements:
    - Add retry policies for `Create_Policy_Exemption`, `Create_Fabric_Capacity`, and `Remove_Policy_Exemption` (e.g., 2 retries with exponential backoff).
    - Add scope-level `Configure run after` on cleanup to ensure `Remove_Policy_Exemption` runs on success or partial failures where exemption exists.
    - Add a final `catch-all` scope to send an incident email and attempt cleanup if any unexpected failure occurs.

## RBAC & Identity

- Enable system-assigned managed identity for the Logic App.
- Assign the following minimum permissions to the identity:
    - `Microsoft.Authorization/policyExemptions/*` (create/delete) — Role: Policy Exemption Contributor
    - `Microsoft.Fabric/capacities/*` (create) — Role: Contributor or a Fabric-specific role
    - `Microsoft.Resources/deployments/*` if you later use ARM deployments
- Office365 and Teams connectors require configured connections in the Logic App parameters (`$connections`).

## Testing

### Example PowerShell test payload

```powershell
$body = @{
    subscriptionId = "00000000-0000-0000-0000-000000000000"
    resourceGroup = "fabric-rg"
    location = "eastus"
    capacityName = "fabriccapacity001"
    skuName = "F4"
    adminMembers = "user@contoso.com"
    policyAssignmentId = "/subscriptions/<SUBSCRIPTION_ID>/providers/Microsoft.Authorization/policyAssignments/<ASSIGNMENT_ID>"
    requesterEmail = "requester@contoso.com"
    justification = "Project X requires capacity"
} | ConvertTo-Json

Invoke-RestMethod -Method Post -Uri "https://<logic-app-url>/triggers/manual/invoke?api-version=2016-10-01" -Body $body -ContentType "application/json"
```

### Test cases
- Happy path: valid data, approver selects Approve, capacity is created and exemption removed.
- Rejection path: valid data, approver selects Reject, capacity not created.
- Validation failure: invalid capacity name or admin member, validation email sent.
- Partial failure: exemption created but capacity creation fails — ensure cleanup runs.

## Deployment

- Deploy the Logic App via ARM template or paste the JSON into the Logic App code view.
- Ensure the `$connections` parameter is populated with valid connection resource IDs for Teams and Office365.
- CI/CD: consider a GitHub Actions job that uses `az deployment group create` to deploy the Logic App JSON and update connections.

## Troubleshooting

- 401/403 on HTTP actions: check Managed Identity assignment and RBAC roles.
- 400 on capacity creation: inspect request body and SKU validity.
- Teams/Office365 connector failures: verify `$connections` values and connector resource existence.

## Security considerations

- Limit the managed identity scope to only required resource groups/subscriptions.
- Keep exemption windows as small as possible.
- Audit exemption creation/deletion via Activity Logs and alerts.

## Next steps (suggested)

- Add retries and improve cleanup logic in the workflow JSON.
- Move complex validation to an Azure Function for better testability.
- Add an approval escalation path and audit logging.
- Add monitoring dashboards for exemption usage and capacity provisioning.

---

Generated from: `infra/logic-apps/fabric-capacity-approval-workflow.json`
{
    "subscriptionId": "12345678-1234-5678-1234-567812345678",
    "resourceGroup": "fabric-rg",
    "location": "eastus",
    "capacityName": "fabriccapacity001",
    "skuName": "F4",
    "adminMembers": "user@contoso.com,serviceprincial@contoso.com",
    "requesterEmail": "requester@contoso.com",
    "justification": "Required for new BI project"
}
```

### Teams Approval Card
```yaml
Title: Fabric Capacity Approval Request
Details:
  - Requester: [requester@contoso.com]
  - Capacity Name: fabriccapacity001
  - SKU: F4
  - Location: East US
  - Resource Group: fabric-rg
Justification: Required for new BI project
Actions:
  - Approve
  - Reject
  - Request More Information
```

## Next Steps
1. Would you like me to create the actual Logic App workflow definition?
2. Should I create the Teams adaptive card templates?
3. Would you like me to set up the monitoring components?
4. Should I create a sample client application to invoke the Logic App?