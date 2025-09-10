# Corrected Role Assignments for Logic App

## Required Roles

1. **Fabric Administrator** (Built-in role)
   - Found under "Job Function Roles" in Azure Portal
   - Used for managing Fabric capacities

2. **Custom Role for Policy Exemption** (We need to create this)

## Creating Custom Policy Exemption Role

### Option 1: Using Azure Portal
1. Go to your subscription
2. Click on **Access control (IAM)**
3. Click **Add** > **Add custom role**
4. Fill in the basics:
   - Name: "Policy Exemption Contributor"
   - Description: "Can create and manage policy exemptions"

5. In **Permissions** tab, add these permissions:
```json
{
    "permissions": [
        {
            "actions": [
                "Microsoft.Authorization/policyExemptions/*",
                "Microsoft.Authorization/policyAssignments/read",
                "Microsoft.Authorization/policyDefinitions/read",
                "Microsoft.Authorization/policySetDefinitions/read"
            ],
            "notActions": [],
            "dataActions": [],
            "notDataActions": []
        }
    ]
}
```

### Option 2: Using PowerShell
```powershell
# Create custom role definition
$role = @{
    Name = 'Policy Exemption Contributor'
    Description = 'Can create and manage policy exemptions'
    Actions = @(
        'Microsoft.Authorization/policyExemptions/*',
        'Microsoft.Authorization/policyAssignments/read',
        'Microsoft.Authorization/policyDefinitions/read',
        'Microsoft.Authorization/policySetDefinitions/read'
    )
    AssignableScopes = @(
        '/subscriptions/your-subscription-id'
    )
}

$roleDefinition = New-AzRoleDefinition -Role $role
```

### Option 3: Using Azure CLI
```bash
# Create a JSON file for the role definition
cat > policy-exemption-role.json << EOF
{
    "Name": "Policy Exemption Contributor",
    "Description": "Can create and manage policy exemptions",
    "Actions": [
        "Microsoft.Authorization/policyExemptions/*",
        "Microsoft.Authorization/policyAssignments/read",
        "Microsoft.Authorization/policyDefinitions/read",
        "Microsoft.Authorization/policySetDefinitions/read"
    ],
    "AssignableScopes": [
        "/subscriptions/your-subscription-id"
    ]
}
EOF

# Create the role
az role definition create --role-definition policy-exemption-role.json
```

## Assigning Roles to Logic App

### Using Azure Portal
1. Go to your subscription
2. Click on **Access control (IAM)**
3. Click **Add** > **Add role assignment**
4. Make two role assignments:

   **First Assignment:**
   - Role: **Fabric Administrator** (under Job Function Roles)
   - Assign access to: **Managed Identity**
   - Select your Logic App

   **Second Assignment:**
   - Role: **Policy Exemption Contributor** (your custom role)
   - Assign access to: **Managed Identity**
   - Select your Logic App

### Alternative: Using PowerShell
```powershell
# Variables
$subscriptionId = "your-subscription-id"
$resourceGroupName = "your-resource-group"
$logicAppName = "your-logic-app-name"

# Get the Logic App's managed identity object ID
$logicApp = Get-AzLogicApp -ResourceGroupName $resourceGroupName -Name $logicAppName
$principalId = $logicApp.Identity.PrincipalId

# Assign Fabric Administrator role
New-AzRoleAssignment `
    -ObjectId $principalId `
    -RoleDefinitionName "Fabric Administrator" `
    -Scope "/subscriptions/$subscriptionId"

# Assign custom Policy Exemption role
New-AzRoleAssignment `
    -ObjectId $principalId `
    -RoleDefinitionName "Policy Exemption Contributor" `
    -Scope "/subscriptions/$subscriptionId"
```

## Verifying Role Assignments
1. Go to your subscription
2. Click on **Access control (IAM)**
3. Click on **Role assignments**
4. Filter by your Logic App name
5. You should see both:
   - Fabric Administrator
   - Policy Exemption Contributor (custom)

## Important Notes
1. Creating custom roles requires high privileges (Owner or User Access Administrator)
2. Role assignments may take up to 30 minutes to propagate
3. The custom role can be scoped to subscription or resource group level
4. Ensure your account has sufficient permissions to create custom roles

## Troubleshooting
1. If you can't create custom roles:
   - Verify you have Owner or User Access Administrator role
   - Check if you have any policy restrictions
2. If roles don't appear immediately:
   - Wait for role propagation (up to 30 minutes)
   - Clear browser cache and refresh
3. If you get permission errors in Logic App:
   - Verify both roles are assigned correctly
   - Check the role assignments in Azure Portal