# Setting Up Managed Identity for Logic App

## 1. Enable System-assigned Managed Identity

### Option 1: Using Azure Portal
1. Navigate to your Logic App in Azure Portal
2. Click on **Identity** in the left menu
3. Under the **System assigned** tab
4. Switch **Status** to **On**
5. Click **Save**
6. You'll see a notification confirming the identity has been created
7. Note down the **Object ID** - you'll need this for role assignments

### Option 2: Using Azure PowerShell
```powershell
# Login to Azure (if not already logged in)
Connect-AzAccount

# Set your subscription
Set-AzContext -SubscriptionId "your-subscription-id"

# Enable system-assigned managed identity
$logicApp = Set-AzLogicApp `
    -ResourceGroupName "your-resource-group" `
    -Name "your-logic-app-name" `
    -IdentityType "SystemAssigned"

# Get the principal ID (object ID) of the managed identity
$principalId = $logicApp.Identity.PrincipalId
Write-Host "Managed Identity Object ID: $principalId"
```

### Option 3: Using Azure CLI
```bash
# Login to Azure (if not already logged in)
az login

# Set your subscription
az account set --subscription "your-subscription-id"

# Enable system-assigned managed identity
az logic workflow identity assign \
    --name "your-logic-app-name" \
    --resource-group "your-resource-group" \
    --identities [system]

# Get the principal ID (object ID)
az logic workflow identity show \
    --name "your-logic-app-name" \
    --resource-group "your-resource-group" \
    --query principalId -o tsv
```

## 2. Assign Required RBAC Roles

### Option 1: Using Azure Portal
1. Navigate to your subscription or resource group
2. Click on **Access control (IAM)**
3. Click **Add** > **Add role assignment**
4. Select the role:
   - First role: **Policy Exemption Contributor**
   - Second role: **Fabric Administrator**
5. In **Assign access to**, select **Managed Identity**
6. Click **Select members**
7. In **Managed Identity**, choose **Logic App**
8. Select your Logic App from the list
9. Click **Select**
10. Click **Review + assign**
11. Repeat for each required role

### Option 2: Using PowerShell
```powershell
# Variables
$subscriptionId = "your-subscription-id"
$resourceGroupName = "your-resource-group"
$logicAppName = "your-logic-app-name"

# Get the Logic App's managed identity object ID
$logicApp = Get-AzLogicApp -ResourceGroupName $resourceGroupName -Name $logicAppName
$principalId = $logicApp.Identity.PrincipalId

# Assign Policy Exemption Contributor role
New-AzRoleAssignment `
    -ObjectId $principalId `
    -RoleDefinitionName "Policy Exemption Contributor" `
    -Scope "/subscriptions/$subscriptionId"

# Assign Fabric Administrator role
New-AzRoleAssignment `
    -ObjectId $principalId `
    -RoleDefinitionName "Fabric Administrator" `
    -Scope "/subscriptions/$subscriptionId"
```

### Option 3: Using Azure CLI
```bash
# Variables
subscriptionId="your-subscription-id"
resourceGroup="your-resource-group"
logicAppName="your-logic-app-name"

# Get the Logic App's managed identity object ID
principalId=$(az logic workflow identity show \
    --name $logicAppName \
    --resource-group $resourceGroup \
    --query principalId -o tsv)

# Assign Policy Exemption Contributor role
az role assignment create \
    --assignee-object-id $principalId \
    --assignee-principal-type ServicePrincipal \
    --role "Policy Exemption Contributor" \
    --scope "/subscriptions/$subscriptionId"

# Assign Fabric Administrator role
az role assignment create \
    --assignee-object-id $principalId \
    --assignee-principal-type ServicePrincipal \
    --role "Fabric Administrator" \
    --scope "/subscriptions/$subscriptionId"
```

## 3. Verify Role Assignments

### Using Azure Portal
1. Go to your subscription or resource group
2. Click on **Access control (IAM)**
3. Click on **Role assignments**
4. In the filter, enter your Logic App name
5. Verify you see both required roles assigned

### Using PowerShell
```powershell
# Get role assignments for the Logic App's managed identity
Get-AzRoleAssignment -ObjectId $principalId
```

### Using Azure CLI
```bash
# Get role assignments for the Logic App's managed identity
az role assignment list --assignee $principalId -o table
```

## Common Issues and Troubleshooting

1. **Role Assignment Delay**
   - Role assignments can take up to 30 minutes to propagate
   - If you get authentication errors, wait and try again

2. **Missing Permissions**
   - Ensure you have sufficient permissions to assign roles
   - You need to be an Owner or User Access Administrator

3. **Scope Issues**
   - Make sure roles are assigned at the correct scope
   - For cross-subscription access, assign at subscription level

4. **Identity Not Showing**
   - If managed identity doesn't appear in role assignment
   - Verify identity is enabled and status is "On"
   - Check for any error messages in Activity Log