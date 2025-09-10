# Policy: Deny Microsoft Fabric capacity creation

This folder contains a custom Azure Policy that prevents creation of Microsoft Fabric capacities to enforce centralized approval and governance. It includes a small `metadata.documentation` block inside the JSON to provide human-readable guidance (JSON doesn't support comments).

Files
- `policy-deny-fabric-capacity.json` - The custom policy definition. The policy denies any resource whose type equals `Microsoft.Fabric/capacities`.

Why this policy exists
- Prevents unapproved or ad-hoc provisioning of Fabric capacity which can have cost and governance implications.
- Centralizes requests for capacity creation through an approval process or designated automation.

How the documentation is included
- JSON has no native comment support. To keep explanations near the policy, supplemental text was added under `properties.metadata.documentation`. Azure Policy ignores unknown metadata fields, so these annotations are safe for deployment.

Quick deploy (CLI)

1) Create the policy definition

```powershell
az policy definition create --name "deny-fabric-capacity" --display-name "Deny Microsoft Fabric capacity creation" --description "Blocks creation of Microsoft.Fabric/capacities to enforce central approval." --rules "policy-deny-fabric-capacity.json" --mode All
```

2) Assign the policy to a scope (subscription or resource group)

```powershell
az policy assignment create --name "deny-fabric-capacity-assignment" --scope "/subscriptions/<SUBSCRIPTION_ID>" --policy "deny-fabric-capacity"
```

Exemptions
- To allow specific resource groups or principals to create capacities, use Policy Exemptions.

PowerShell example (create an exemption):

```powershell
az policy exemption create --name "exempt-my-team" --policy-assignment "/subscriptions/<SUBSCRIPTION_ID>/providers/Microsoft.Authorization/policyAssignments/deny-fabric-capacity-assignment" --scope "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/my-exempt-rg" --exemption-category "Waiver"
```

JSON example (exemption resource template)

Below is a minimal example of the exemption resource as an ARM template (useful for automation or CI/CD pipelines). Replace placeholders before deployment.

```json
{
	"$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
	"contentVersion": "1.0.0.0",
	"resources": [
		{
			"type": "Microsoft.Authorization/policyExemptions",
			"apiVersion": "2021-06-01",
			"name": "exempt-my-team",
			"properties": {
				"policyAssignmentId": "/subscriptions/<SUBSCRIPTION_ID>/providers/Microsoft.Authorization/policyAssignments/deny-fabric-capacity-assignment",
				"exemptionCategory": "Waiver",
				"displayName": "Exemption for My Team",
				"description": "Allows resources in my-exempt-rg to create Fabric capacities",
				"expiresOn": "2030-12-31T23:59:59Z",
				"scope": "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/my-exempt-rg",
				"metadata": {
					"requestedBy": "team@example.com",
					"justification": "Approved by platform team for project X"
				}
			}
		}
	]
}
```

Notes
- The policy uses the `deny` effect. For monitoring-only use `audit` instead.
- Adjust the rule if you want to allow specific SKUs or add more complex logic (e.g., allow if a tag `approved:true` is present).

Contact
- For requests to provision Fabric capacity or to request exemptions, contact the cloud platform team.