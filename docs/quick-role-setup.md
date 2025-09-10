# Quick Role Setup Guide

## Prerequisites
```powershell
# Install required Az modules if not already installed
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
Install-Module -Name Az.LogicApp -Scope CurrentUser -Repository PSGallery -Force

# Import modules
Import-Module Az
Import-Module Az.LogicApp

# Connect to Azure (if not already connected)
Connect-AzAccount

# Set your subscription
Set-AzContext -SubscriptionId "95ad0027-ffa7-4f15-8a92-76112d0073d9"
```

## 1. Fabric Capacity Administrator (Built-in Role)
```powershell
# Variables
$subscriptionId = "95ad0027-ffa7-4f15-8a92-76112d0073d9"
$resourceGroupName = "fabricRG"
$logicAppName = "ApprovalLogic"

# Enable system-assigned managed identity for the Logic App
Update-AzLogicApp -ResourceGroupName $resourceGroupName -Name $logicAppName -IdentityType SystemAssigned

# Get Logic App's managed identity object ID (wait a few seconds after enabling)
Start-Sleep -Seconds 10  # Wait for identity to propagate
$logicApp = Get-AzLogicApp -ResourceGroupName $resourceGroupName -Name $logicAppName
$principalId = $logicApp.Identity.PrincipalId

# Verify the principal ID is not empty
if ([string]::IsNullOrEmpty($principalId)) {
    Write-Error "Managed identity is not properly enabled. Please check the Logic App in the Azure Portal."
    return
}

Write-Host "Managed Identity Principal ID: $principalId"

# Assign Fabric Capacity Administrator role
New-AzRoleAssignment `
    -ObjectId $principalId `
    -RoleDefinitionName "Fabric Capacity Administrator" `
    -Scope "/subscriptions/$subscriptionId"
```

## 2. Policy Exemption Role (Custom Role)
```powershell
# 1. Create the custom role
$exemptionRole = @{
    Name = 'Policy Exemption Contributor'
    Description = 'Can create and manage policy exemptions'
    Actions = @(
        'Microsoft.Authorization/policyExemptions/*',
        'Microsoft.Authorization/policyAssignments/read',
        'Microsoft.Authorization/policyDefinitions/read',
        'Microsoft.Authorization/policySetDefinitions/read'
    )
    AssignableScopes = @(
        "/subscriptions/$subscriptionId"
    )
}

# Create the role definition
$roleDefinition = New-AzRoleDefinition -Role $exemptionRole

# 2. Assign the custom role
New-AzRoleAssignment `
    -ObjectId $principalId `
    -RoleDefinitionName "Policy Exemption Contributor" `
    -Scope "/subscriptions/$subscriptionId"
```

## Quick Portal Steps
1. Go to subscription → Access control (IAM)
2. Click "Add" → "Add role assignment"
3. Select "Fabric Capacity Administrator" role (search for it if not immediately visible)
4. Select your Logic App's managed identity
5. Click "Review + assign"
6. Repeat steps 1-5 for the custom "Policy Exemption Contributor" role

## Verify
```powershell
# Check role assignments
Get-AzRoleAssignment -ObjectId $principalId
```

Note: Allow up to 30 minutes for role assignments to propagate.